# frozen_string_literal: true

require "thor"
require_relative "output_formatter"
require_relative "../client"

module W3cApi
  module Commands
    # Thor CLI command for series operations
    class Series < Thor
      include OutputFormatter

      desc "fetch [OPTIONS]", "Fetch specification series"
      option :shortname, type: :string, desc: "Series shortname"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def fetch
        client = W3cApi::Client.new

        series = if options[:shortname]
                   # Single series
                   client.series_by_shortname(options[:shortname])
                 else
                   # All series
                   client.series
                 end

        output_results(series, options[:format])
      end

      desc "specifications", "Fetch specifications in a series"
      option :shortname, type: :string, required: true, desc: "Series shortname"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def specifications
        client = W3cApi::Client.new
        specifications = client.series_specifications(options[:shortname])
        output_results(specifications, options[:format])
      end
    end
  end
end
