# frozen_string_literal: true

require "thor"
require_relative "output_formatter"
require_relative "../client"

module W3cApi
  module Commands
    # Thor CLI command for participation operations
    class Participation < Thor
      include OutputFormatter

      desc "fetch", "Fetch a participation by ID"
      option :id, type: :numeric, required: true, desc: "Participation ID"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def fetch
        client = W3cApi::Client.new
        participation = client.participation(options[:id])
        output_results(participation, options[:format])
      end

      desc "participants", "Fetch participants in a participation"
      option :id, type: :numeric, required: true, desc: "Participation ID"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def participants
        client = W3cApi::Client.new
        participants = client.participation_participants(options[:id])
        output_results(participants, options[:format])
      end
    end
  end
end
