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
end
