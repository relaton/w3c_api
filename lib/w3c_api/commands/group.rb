# frozen_string_literal: true

require "thor"
require_relative "output_formatter"
require_relative "../client"

module W3cApi
  module Commands
    # Thor CLI command for group operations
    class Group < Thor
      include OutputFormatter

      desc "fetch [OPTIONS]", "Fetch groups"
      option :id, type: :string, desc: "Group ID"
      option :type, type: :string, desc: "Group type"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def fetch
        client = W3cApi::Client.new

        groups = if options[:id]
                   # Single group
                   client.group(options[:id])
                 elsif options[:type]
                   client.groups(type: options[:type])
                 else
                   client.groups
                 end

        output_results(groups, options[:format])
      end

      desc "users", "Fetch users in a group"
      option :id, type: :numeric, required: true, desc: "Group ID"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def users
        client = W3cApi::Client.new
        users = client.group_users(options[:id])
        output_results(users, options[:format])
      end

      desc "specifications", "Fetch specifications produced by a group"
      option :id, type: :numeric, required: true, desc: "Group ID"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def specifications
        client = W3cApi::Client.new
        specifications = client.group_specifications(options[:id])
        output_results(specifications, options[:format])
      end

      desc "charters", "Fetch charters of a group"
      option :id, type: :numeric, required: true, desc: "Group ID"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def charters
        client = W3cApi::Client.new
        charters = client.group_charters(options[:id])
        output_results(charters, options[:format])
      end

      desc "chairs", "Fetch chairs of a group"
      option :id, type: :numeric, required: true, desc: "Group ID"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def chairs
        client = W3cApi::Client.new
        chairs = client.group_chairs(options[:id])
        output_results(chairs, options[:format])
      end

      desc "team-contacts", "Fetch team contacts of a group"
      option :id, type: :numeric, required: true, desc: "Group ID"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def team_contacts
        client = W3cApi::Client.new
        team_contacts = client.group_team_contacts(options[:id])
        output_results(team_contacts, options[:format])
      end

      desc "participations", "Fetch participations in a group"
      option :id, type: :numeric, required: true, desc: "Group ID"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def participations
        client = W3cApi::Client.new
        participations = client.group_participations(options[:id])
        output_results(participations, options[:format])
      end
    end
  end
end
