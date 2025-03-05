# frozen_string_literal: true

require 'thor'
require_relative 'output_formatter'

module W3c
  module Api
    module Cli
      # Thor CLI command for specification operations
      class Specification < Thor
        include OutputFormatter

        desc 'fetch [OPTIONS]', 'Fetch specifications'
        option :shortname, type: :string, desc: 'Filter by shortname'
        option :format, type: :string, default: 'json', enum: %w[json yaml], desc: 'Output format'
        def fetch
          client = W3c::Api::Client.new

          specifications = if options[:shortname]
                             # Single specification wrapped in a collection
                             spec = client.specification(options[:shortname])
                             Models::Specifications.new(specifications: [spec])
                           else
                             client.specifications
                           end

          output_results(specifications, options[:format])
        end

        desc 'versions', 'Fetch versions of a specification'
        option :shortname, type: :string, required: true, desc: 'Specification shortname'
        option :format, type: :string, default: 'json', enum: %w[json yaml], desc: 'Output format'
        def versions
          client = W3c::Api::Client.new
          versions = client.specification_versions(options[:shortname])
          output_results(versions, options[:format])
        end
      end
    end
  end
end
