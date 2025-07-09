# frozen_string_literal: true

require "thor"
require_relative "output_formatter"

module W3cApi
  module Commands
    class SpecificationVersion < Thor
      include OutputFormatter

      desc "editors", "Fetch editors of a specification version"
      option :shortname, type: :string, required: true,
                         desc: "Specification shortname"
      option :version, type: :string, required: true,
                       desc: "Specification version"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def editors
        client = W3cApi::Client.new
        result = client.specification_version_editors(options[:shortname],
                                                      options[:version])
        output_results(result, options[:format])
      rescue StandardError => e
        puts "Error: #{e.message}"
        exit 1
      end

      desc "deliverers",
           "Fetch deliverers (working groups) of a specification version"
      option :shortname, type: :string, required: true,
                         desc: "Specification shortname"
      option :version, type: :string, required: true,
                       desc: "Specification version"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def deliverers
        client = W3cApi::Client.new
        result = client.specification_version_deliverers(options[:shortname],
                                                         options[:version])
        output_results(result, options[:format])
      rescue StandardError => e
        puts "Error: #{e.message}"
        exit 1
      end
    end
  end
end
