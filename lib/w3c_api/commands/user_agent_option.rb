# frozen_string_literal: true

require_relative "../hal"

module W3cApi
  module Commands
    # Adds a --user-agent flag to a command class and applies it before the
    # command runs. Thor cannot parse options that precede a subcommand name,
    # so the flag lives on each command class rather than on the root Cli:
    #
    #   w3c_api specification fetch --user-agent "my-crawler/1.0 (+url)"
    module UserAgentOption
      def self.included(base)
        base.class_option :user_agent,
                          type: :string,
                          desc: "User-Agent sent to api.w3.org " \
                                "(default: #{Hal::DEFAULT_USER_AGENT})"
      end

      def initialize(*args)
        super
        # Configure before the command body builds a Client: changing the user
        # agent rebuilds the connection, client and register.
        Hal.instance.configure_user_agent(options[:user_agent]) if options[:user_agent]
      end
    end
  end
end
