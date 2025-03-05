# frozen_string_literal: true

require 'thor'
require_relative 'output_formatter'
require_relative '../client'

module W3c
  module Api
    module Commands
      # Thor CLI command for translation operations
      class Translation < Thor
        include OutputFormatter

        desc 'fetch [OPTIONS]', 'Fetch a translation by ID'
        option :id, type: :string, desc: 'Translation ID'
        option :format, type: :string, default: 'yaml', enum: %w[json yaml], desc: 'Output format'
        def fetch
          client = W3c::Api::Client.new

          translations = if options[:id]
                           # Single specification version
                           client.translation(options[:id])
                         else
                           # All translations
                           client.translations
                         end

          output_results(translations, options[:format])
        end
      end
    end
  end
end
