# frozen_string_literal: true

require 'thor'
require_relative 'output_formatter'

module W3c
  module Api
    module Cli
      # Thor CLI command for service operations
      class Service < Thor
        include OutputFormatter

        desc 'fetch [OPTIONS]', 'Fetch services'
        option :type, type: :string, desc: 'Service type'
        option :format, type: :string, default: 'json', enum: %w[json yaml], desc: 'Output format'
        def fetch
          client = W3c::Api::Client.new

          services = if options[:type]
                       # Single service wrapped in a collection
                       service = client.service(options[:type])
                       Models::Services.new(services: [service])
                     else
                       client.services
                     end

          output_results(services, options[:format])
        end
      end
    end
  end
end
