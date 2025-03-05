# frozen_string_literal: true

require_relative 'cli/commands'

module W3c
  module Api
    # Main CLI class entry point
    class Cli < Thor
      # Delegate to the Cli::Commands class
      def self.start(given_args = ARGV, config = {})
        Cli::Commands.start(given_args, config)
      end
    end
  end
end
