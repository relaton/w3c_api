# frozen_string_literal: true

require 'thor'
require_relative 'output_formatter'
require_relative '../client'

module W3c
  module Api
    module Commands
      # Thor CLI command for specification operations
      class Specification < Thor
        include OutputFormatter

        desc 'fetch [OPTIONS]', 'Fetch specifications'
        option :shortname, type: :string, desc: 'Filter by shortname'
        option :version, type: :string, desc: 'Specific version of the specification'
        option :status, type: :string, desc: 'Filter by status'
        option :format, type: :string, default: 'yaml', enum: %w[json yaml], desc: 'Output format'
        def fetch
          client = W3c::Api::Client.new

          specifications = if options[:shortname] && options[:version]
                             # Single specification version
                             client.specification_version(options[:shortname], options[:version])
                           elsif options[:shortname]
                             # Single specification
                             client.specification(options[:shortname])
                           elsif options[:status]
                             # Specifications by status
                             client.specifications_by_status(options[:status])
                           else
                             # All specifications
                             client.specifications
                           end

          output_results(specifications, options[:format])
        end

        desc 'versions', 'Fetch versions of a specification'
        option :shortname, type: :string, required: true, desc: 'Specification shortname'
        option :format, type: :string, default: 'yaml', enum: %w[json yaml], desc: 'Output format'
        def versions
          client = W3c::Api::Client.new
          versions = client.specification_versions(options[:shortname])
          output_results(versions, options[:format])
        end

        desc 'supersedes', 'Fetch specifications that this specification supersedes'
        option :shortname, type: :string, required: true, desc: 'Specification shortname'
        option :format, type: :string, default: 'yaml', enum: %w[json yaml], desc: 'Output format'
        def supersedes
          # We need to add client.specification_supersedes method in the client
          client = W3c::Api::Client.new
          specifications = client.specification_supersedes(options[:shortname])
          output_results(specifications, options[:format])
        end

        desc 'superseded-by', 'Fetch specifications that supersede this specification'
        option :shortname, type: :string, required: true, desc: 'Specification shortname'
        option :format, type: :string, default: 'yaml', enum: %w[json yaml], desc: 'Output format'
        def superseded_by
          # We need to add client.specification_superseded_by method in the client
          client = W3c::Api::Client.new
          specifications = client.specification_superseded_by(options[:shortname])
          output_results(specifications, options[:format])
        end
      end
    end
  end
end
