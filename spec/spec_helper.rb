# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_group 'Models', 'lib/w3c/api/models'
  add_group 'Client', 'lib/w3c/api/client'
  add_group 'Cli', 'lib/w3c/api/cli'
end

require 'w3c_api'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :faraday
  config.configure_rspec_metadata!
  config.default_cassette_options = {
    record: :new_episodes,
    match_requests_on: %i[method uri body]
  }
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Clean up global register before each test to avoid conflicts
  config.before(:each) do
    # Reset the cached register in the singleton before unregistering
    W3cApi::Hal.instance.reset_register
    Lutaml::Hal::GlobalRegister.instance.unregister(:w3c_api)
    # Ensure the register is available for tests that need it
    W3cApi::Hal.instance.register
  end

  # Clean up global register after each test
  config.after(:each) do
    Lutaml::Hal::GlobalRegister.instance.unregister(:w3c_api)
  end
end
