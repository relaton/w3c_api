# frozen_string_literal: true

require "spec_helper"

RSpec.describe W3cApi::Commands::UserAgentOption do
  # Keep a W3C_API_USER_AGENT exported in the developer's shell out of the way.
  before do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch)
      .with(W3cApi::Hal::USER_AGENT_ENV_VAR, nil).and_return(nil)
    W3cApi::Hal.instance.configure_user_agent(nil)
  end

  # Every command class mixes this in, so the flag is available on each of them.
  let(:command_classes) do
    [
      W3cApi::Commands::Affiliation,
      W3cApi::Commands::Ecosystem,
      W3cApi::Commands::Group,
      W3cApi::Commands::Participation,
      W3cApi::Commands::Series,
      W3cApi::Commands::Specification,
      W3cApi::Commands::SpecificationVersion,
      W3cApi::Commands::Translation,
      W3cApi::Commands::User,
    ]
  end

  it "declares --user-agent on every command class" do
    command_classes.each do |klass|
      expect(klass.class_options).to include(:user_agent),
                                     "#{klass} is missing the --user-agent option"
    end
  end

  it "applies the option to the Hal singleton when given" do
    W3cApi::Commands::Ecosystem.new([], { "user_agent" => "cli-test/1.0" })

    expect(W3cApi::Hal.instance.user_agent).to eq("cli-test/1.0")
  end

  it "leaves the default user agent alone when the option is absent" do
    W3cApi::Commands::Ecosystem.new([], {})

    expect(W3cApi::Hal.instance.user_agent)
      .to eq(W3cApi::Hal::DEFAULT_USER_AGENT)
  end

  it "leaves the default user agent alone when the option is blank" do
    W3cApi::Commands::Ecosystem.new([], { "user_agent" => "" })

    expect(W3cApi::Hal.instance.user_agent)
      .to eq(W3cApi::Hal::DEFAULT_USER_AGENT)
  end
end
