# frozen_string_literal: true

require "spec_helper"

RSpec.describe W3cApi::Hal do
  subject(:hal) { described_class.instance }

  # Make ENV lookups deterministic: the real environment must not leak into the
  # examples, and an example that sets the variable must not leak out of it.
  def stub_user_agent_env(value)
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch)
      .with(described_class::USER_AGENT_ENV_VAR, nil).and_return(value)
    hal.configure_user_agent(nil)
  end

  # A W3C_API_USER_AGENT exported in the developer's shell must not change what
  # these examples see; the ones that care set it explicitly.
  before { stub_user_agent_env(nil) }

  describe "#user_agent" do
    it "identifies the gem, its version and a contact URL" do
      expect(hal.user_agent)
        .to eq("w3c_api/#{W3cApi::VERSION} (+https://github.com/relaton/w3c_api)")
    end

    it "is not a bare HTTP library user agent" do
      expect(hal.user_agent).not_to include("Faraday")
    end

    it "reads the W3C_API_USER_AGENT environment variable" do
      stub_user_agent_env("relaton-crawler/2.0 (+https://example.com)")

      expect(hal.user_agent).to eq("relaton-crawler/2.0 (+https://example.com)")
    end

    it "ignores a blank environment variable" do
      stub_user_agent_env("   ")

      expect(hal.user_agent).to eq(described_class::DEFAULT_USER_AGENT)
    end

    it "prefers an explicitly configured value over the environment" do
      stub_user_agent_env("from-env/1.0")
      hal.configure_user_agent("explicit/1.0")

      expect(hal.user_agent).to eq("explicit/1.0")
    end
  end

  describe "#connection" do
    it "sends the default User-Agent header" do
      expect(hal.connection.headers["User-Agent"])
        .to eq(described_class::DEFAULT_USER_AGENT)
    end
  end

  describe "#configure_user_agent" do
    it "rebuilds the connection, the client and the register" do
      old_connection = hal.connection
      old_client = hal.client
      old_register = hal.register

      hal.configure_user_agent("relaton-w3c/1.2 (+https://example.com)")

      expect(hal.connection).not_to equal(old_connection)
      expect(hal.client).not_to equal(old_client)
      expect(hal.register).not_to equal(old_register)
      # The assertion that proves the whole cascade: the register a request
      # actually goes through carries the new header.
      expect(hal.register.client.connection.headers["User-Agent"])
        .to eq("relaton-w3c/1.2 (+https://example.com)")
    end

    it "restores the default when given nil" do
      hal.configure_user_agent("custom/1.0")
      hal.configure_user_agent(nil)

      expect(hal.connection.headers["User-Agent"])
        .to eq(described_class::DEFAULT_USER_AGENT)
    end

    it "restores the default when given a blank string" do
      hal.configure_user_agent("custom/1.0")
      hal.configure_user_agent("  ")

      expect(hal.user_agent).to eq(described_class::DEFAULT_USER_AGENT)
    end

    it "folds CRLF so a value cannot inject extra headers" do
      hal.configure_user_agent("bad/1.0\r\nX-Injected: 1")

      expect(hal.user_agent).to eq("bad/1.0 X-Injected: 1")
    end

    it "returns the resulting user agent" do
      expect(hal.configure_user_agent("returned/1.0")).to eq("returned/1.0")
    end
  end

  describe "outgoing requests" do
    # record: :none makes VCR raise on a mismatch instead of silently making a
    # real request (the global default is :new_episodes).
    it "sends the configured User-Agent on the wire" do
      hal.configure_user_agent("wire-test/1.0 (+https://example.com)")

      response = VCR.use_cassette("ecosystems", record: :none) do
        hal.connection.get("/ecosystems")
      end

      expect(response.env.request_headers["User-Agent"])
        .to eq("wire-test/1.0 (+https://example.com)")
    end

    it "lets a per-request header override the connection default" do
      response = VCR.use_cassette("ecosystems", record: :none) do
        hal.connection.get("/ecosystems") do |req|
          req.headers["User-Agent"] = "PerRequest/9.9"
        end
      end

      expect(response.env.request_headers["User-Agent"]).to eq("PerRequest/9.9")
    end
  end

  describe "#configure_rate_limiting" do
    # The singleton keeps these options process-wide; restore them fully.
    around do |example|
      saved = hal.rate_limiting_options.dup
      example.run
      hal.configure_rate_limiting(saved)
    end

    it "rebuilds the register so it cannot keep a stale client" do
      old_register = hal.register

      hal.configure_rate_limiting(max_retries: 1)

      expect(hal.register).not_to equal(old_register)
      expect(hal.register.client).to equal(hal.client)
      expect(hal.rate_limiting_options[:max_retries]).to eq(1)
    end
  end

  # Link#realize resolves the register through lutaml-hal's GlobalRegister,
  # which raises when the name is absent — so a configuration change must never
  # leave the register torn down, or every model fetched beforehand loses its
  # ability to realize links.
  describe "register availability after a configuration change" do
    def registered_register
      Lutaml::Hal::GlobalRegister.instance.get(:w3c_api)
    end

    it "keeps the register globally registered after configure_user_agent" do
      hal.register
      hal.configure_user_agent("realize-test/1.0")

      expect(registered_register).to equal(hal.register)
    end

    it "keeps the register globally registered after configure_rate_limiting" do
      saved = hal.rate_limiting_options.dup
      hal.register
      hal.configure_rate_limiting(max_retries: 3)

      expect(registered_register).to equal(hal.register)
    ensure
      hal.configure_rate_limiting(saved)
    end

    it "keeps the register globally registered after configure_cache" do
      hal.register
      hal.configure_cache(adapter: :memory)

      expect(registered_register).to equal(hal.register)
    end

    it "keeps the register globally registered after disable_cache" do
      hal.register
      hal.disable_cache

      expect(registered_register).to equal(hal.register)
    ensure
      hal.enable_cache
    end
  end

  # Everything below covers the Faraday retry layer (issue #23).
  #
  # Scoped rather than file-level on purpose: these examples turn VCR off, and
  # the cassette-backed "outgoing requests" group above needs it on.
  describe "retry policy" do
    # spec_helper's per-example configure_user_agent(nil) rebuilds the
    # connection, client and register, but nothing resets @retry_options -- so a
    # configure_retry call here would otherwise persist for the whole suite
    # process. `around` rather than before/after: an example that raises would
    # skip the restore.
    #
    # VCR's `hook_into :faraday` patches Faraday::RackBuilder, so VCR middleware
    # lands in *every* connection, including the Faraday::Adapter::Test one built
    # below. With no cassette in play VCR classifies that request as unhandled
    # and raises before the test adapter is reached, so turn VCR off throughout.
    around do |example|
      saved_retry_options = hal.instance_variable_get(:@retry_options)

      VCR.turned_off(ignore_cassettes: true) { example.run }
    ensure
      hal.instance_variable_set(:@retry_options, saved_retry_options)
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

    describe "the shipped connection" do
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

      it "rebuilds the register so it cannot keep a stale client" do
        old_register = hal.register

        hal.configure_retry(max: 2)

        expect(hal.register).not_to equal(old_register)
        expect(hal.register.client).to equal(hal.client)
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
end
