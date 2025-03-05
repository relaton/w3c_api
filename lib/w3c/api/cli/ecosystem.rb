# frozen_string_literal: true

require 'thor'
require_relative 'output_formatter'

module W3c
  module Api
    module Cli
      # Thor CLI command for ecosystem operations
      class Ecosystem < Thor
        include OutputFormatter

        desc 'fetch [OPTIONS]', 'Fetch ecosystems'
        option :shortname, type: :string, desc: 'Ecosystem shortname'
        option :format, type: :string, default: 'json', enum: %w[json yaml], desc: 'Output format'
        def fetch
          client = W3c::Api::Client.new

          ecosystems = if options[:shortname]
                         # Single ecosystem wrapped in a collection
                         ecosystem = client.ecosystem(options[:shortname])
                         Models::Ecosystems.new(ecosystems: [ecosystem])
                       else
                         client.ecosystems
                       end

          output_results(ecosystems, options[:format])
        end
      end
    end
  end
end
