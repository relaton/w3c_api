# frozen_string_literal: true

require 'thor'
require_relative 'output_formatter'

module W3c
  module Api
    module Cli
      # Thor CLI command for translation operations
      class Translation < Thor
        include OutputFormatter

        desc 'fetch [OPTIONS]', 'Fetch translations'
        option :uri, type: :string, desc: 'Translation URI'
        option :format, type: :string, default: 'json', enum: %w[json yaml], desc: 'Output format'
        def fetch
          client = W3c::Api::Client.new

          translations = if options[:uri]
                           # Single translation wrapped in a collection
                           translation = client.translation(options[:uri])
                           Models::Translations.new(translations: [translation])
                         else
                           client.translations
                         end

          output_results(translations, options[:format])
        end
      end
    end
  end
end
