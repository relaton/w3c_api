# frozen_string_literal: true

require "spec_helper"

RSpec.describe W3cApi::Hal do
  subject(:hal) { described_class.instance }

  # `Hal` is a Singleton that memoizes @retry_options/@connection/@client for
  # the lifetime of the suite process -- spec_helper's per-example reset only
  # clears @register -- so everything this file touches has to be put back.
  # An `around` hook rather than before/after: an example that raises would
  # skip the restore and leak into the rest of the (cassette-backed) suite.
  #
  # VCR's `hook_into :faraday` patches Faraday::RackBuilder, so VCR middleware
  # lands in *every* connection, including the Faraday::Adapter::Test one built
  # below. With no cassette in play VCR classifies that request as unhandled
  # and raises before the test adapter is reached, so turn VCR off throughout.
  around do |example|
    instance = described_class.instance
    saved_retry_options = instance.instance_variable_get(:@retry_options)
    saved_connection = instance.instance_variable_get(:@connection)
    saved_client = instance.instance_variable_get(:@client)

    VCR.turned_off(ignore_cassettes: true) { example.run }
  ensure
    instance.instance_variable_set(:@retry_options, saved_retry_options)
    instance.instance_variable_set(:@connection, saved_connection)
    instance.instance_variable_set(:@client, saved_client)
  end

  describe "#retry_options" do
    it "keeps faraday-retry's default exceptions" do
      expect(hal.retry_options[:exceptions])
        .to include(*Faraday::Retry::Middleware::DEFAULT_EXCEPTIONS)
    end

    # The regression: faraday-retry implements retry_statuses by raising this
    # class internally, so dropping it disables 403 retries entirely.
    it "retries the exception faraday-retry raises for retry_statuses" do
      expect(hal.retry_options[:exceptions])
        .to include(Faraday::RetriableResponse)
    end

    it "still retries connection failures" do
      expect(hal.retry_options[:exceptions])
        .to include(Faraday::ConnectionFailed)
    end

    it "retries HTTP 403, which is how the W3C API signals rate limiting" do
      expect(hal.retry_options[:retry_statuses]).to include(403)
    end

    # The behaviour this number exists for is covered in "Retry-After
    # handling" below; this pins the value itself.
    it "sets max_interval above a realistic Retry-After" do
      expect(hal.retry_options[:max_interval]).to eq(60.0)
    end

    it "does not expose the frozen baseline to mutation" do
      expect { hal.retry_options[:retry_statuses] << 429 }
        .to raise_error(FrozenError)
    end
  end

  describe "#connection" do
    let(:retry_handler) do
      hal.connection.builder.handlers
        .find { |h| h.klass == Faraday::Retry::Middleware }
    end

    it "installs the retry middleware" do
      expect(retry_handler).not_to be_nil
    end

    # The 403 group below drives a connection of its own, so without this the
    # suite would still pass if `connection` handed the middleware a different
    # options hash than the one `retry_options` returns.
    it "hands the middleware the configured retry options" do
      expect(retry_handler.instance_variable_get(:@args))
        .to eq([hal.retry_options])
    end
  end

  describe "#configure_retry" do
    it "merges into the current options rather than replacing them" do
      hal.configure_retry(max: 2)
      expect(hal.retry_options).to include(max: 2, retry_statuses: [403])
    end

    it "leaves DEFAULT_RETRY_OPTIONS untouched" do
      hal.configure_retry(max: 2)
      expect(described_class::DEFAULT_RETRY_OPTIONS[:max]).to eq(5)
    end

    it "resets the memoized connection" do
      original = hal.connection
      hal.configure_retry(max: 2)
      expect(hal.connection).not_to equal(original)
    end

    it "resets the memoized client, which holds the old connection" do
      original = hal.client
      hal.configure_retry(max: 2)
      expect(hal.client).not_to equal(original)
    end
  end

  describe "retrying HTTP 403 (issue #23)" do
    let(:stubs) { Faraday::Adapter::Test::Stubs.new }
    let(:calls) { [] }

    # The production retry options verbatim, with only the timing neutralised
    # so the example is instant. max, retry_statuses and -- crucially --
    # exceptions are exactly what ships.
    let(:connection) do
      hal.configure_retry(interval: 0.0, backoff_factor: 1.0)
      options = hal.retry_options

      Faraday.new(url: described_class::API_URL.delete_suffix("/")) do |conn|
        conn.request :retry, options
        conn.adapter :test, stubs
      end
    end

    before do
      stubs.get("/specifications") do |_env|
        calls << :attempt
        [403, { "Content-Type" => "application/json" }, "{}"]
      end
    end

    # Anchor: if VCR ever intercepts this connection again, this fails too and
    # points at the cause rather than at the retry logic.
    it "passes a non-retriable response straight through" do
      stubs.get("/ok") { [200, { "Content-Type" => "application/json" }, "{}"] }
      expect(connection.get("/ok").status).to eq(200)
    end

    it "does not leak Faraday::RetriableResponse to the caller" do
      expect { connection.get("/specifications") }.not_to raise_error
    end

    it "retries `max` times before giving up" do
      connection.get("/specifications")
      # 1 initial attempt + max (5) retries
      expect(calls.size).to eq(6)
    end

    it "returns the final 403 response once retries are exhausted" do
      expect(connection.get("/specifications").status).to eq(403)
    end
  end

  describe "Retry-After handling" do
    # An end-to-end test would have to sleep for the advertised interval, and
    # shrinking max_interval to avoid that is exactly the condition under test,
    # so assert on faraday-retry's sleep calculation directly.
    let(:middleware) do
      Faraday::Retry::Middleware.new(->(env) { env }, hal.retry_options)
    end

    def sleep_amount_for(retry_after)
      env = Faraday::Env.from(response_headers: { "Retry-After" => retry_after })
      middleware.calculate_sleep_amount(hal.retry_options[:max], env)
    end

    it "waits as long as the server asks when that is within max_interval" do
      expect(sleep_amount_for("45")).to eq(45.0)
    end

    it "accepts a Retry-After exactly at max_interval" do
      expect(sleep_amount_for("60")).to eq(60.0)
    end

    # Documents the sharp edge: above max_interval faraday-retry returns nil,
    # which stops the retry loop rather than waiting longer.
    it "gives up when Retry-After exceeds max_interval" do
      expect(sleep_amount_for("120")).to be_nil
    end
  end
end
