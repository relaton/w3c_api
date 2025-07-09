# frozen_string_literal: true

require "thor"
require_relative "output_formatter"
require_relative "../client"

module W3cApi
  module Commands
    # Thor CLI command for affiliation operations
    class Affiliation < Thor
      include OutputFormatter

      desc "fetch [OPTIONS]", "Fetch affiliations"
      option :id, type: :numeric, desc: "Affiliation ID"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def fetch
        client = W3cApi::Client.new

        affiliations = if options[:id]
                         # Single affiliation
                         client.affiliation(options[:id])
                       else
                         client.affiliations
                       end

        output_results(affiliations, options[:format])
      end

      desc "participants", "Fetch participants of an affiliation"
      option :id, type: :numeric, required: true, desc: "Affiliation ID"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def participants
        client = W3cApi::Client.new
        participants = client.affiliation_participants(options[:id])
        output_results(participants, options[:format])
      end

      desc "participations", "Fetch participations of an affiliation"
      option :id, type: :numeric, required: true, desc: "Affiliation ID"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def participations
        client = W3cApi::Client.new
        participations = client.affiliation_participations(options[:id])
        output_results(participations, options[:format])
      end
    end
  end
end
