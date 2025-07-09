# frozen_string_literal: true

require "thor"
require_relative "output_formatter"
require_relative "../client"

module W3cApi
  module Commands
    # Thor CLI command for specification operations
    class Specification < Thor
      include OutputFormatter

      desc "fetch [OPTIONS]", "Fetch specifications"
      option :shortname, type: :string, desc: "Filter by shortname"
      option :version, type: :string,
                       desc: "Specific version of the specification"
      option :status, type: :string, desc: "Filter by status"
      option :resolve, type: :array,
                       desc: "Links to resolve (e.g. version-history, latest-version, series)"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def fetch
        client = W3cApi::Client.new
        specifications = fetch_specifications(client)
        output_results(specifications, options[:format])
      end

      desc "versions", "Fetch versions of a specification"
      option :shortname, type: :string, required: true,
                         desc: "Specification shortname"
      option :resolve, type: :array, desc: "Links to resolve on each version"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def versions
        client = W3cApi::Client.new
        versions = client.specification_versions(options[:shortname])
        output_results(versions, options[:format])
      end

      desc "supersedes",
           "Fetch specifications that this specification supersedes"
      option :shortname, type: :string, required: true,
                         desc: "Specification shortname"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def supersedes
        # We need to add client.specification_supersedes method in the client
        client = W3cApi::Client.new
        specifications = client.specification_supersedes(options[:shortname])
        output_results(specifications, options[:format])
      end

      desc "superseded-by",
           "Fetch specifications that supersede this specification"
      option :shortname, type: :string, required: true,
                         desc: "Specification shortname"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def superseded_by
        # We need to add client.specification_superseded_by method in the client
        client = W3cApi::Client.new
        specifications = client.specification_superseded_by(options[:shortname])
        output_results(specifications, options[:format])
      end

      desc "editors", "Fetch editors of a specification"
      option :shortname, type: :string, required: true,
                         desc: "Specification shortname"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def editors
        client = W3cApi::Client.new
        editors = client.specification_editors(options[:shortname])
        output_results(editors, options[:format])
      end

      desc "deliverers", "Fetch deliverers (working groups) of a specification"
      option :shortname, type: :string, required: true,
                         desc: "Specification shortname"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def deliverers
        client = W3cApi::Client.new
        deliverers = client.specification_deliverers(options[:shortname])
        output_results(deliverers, options[:format])
      end

      private

      def fetch_specifications(client)
        if options[:shortname] && options[:version]
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
      end
    end
  end
end
