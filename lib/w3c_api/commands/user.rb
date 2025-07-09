# frozen_string_literal: true

require "thor"
require_relative "output_formatter"
require_relative "../client"

module W3cApi
  module Commands
    # Thor CLI command for user operations
    class User < Thor
      include OutputFormatter

      desc "fetch [OPTIONS]", "Fetch a user by ID"
      option :id, type: :string, required: true, desc: "User ID (required)"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def fetch
        client = W3cApi::Client.new
        user = client.user(options[:id])
        output_results(user, options[:format])
      end

      desc "groups", "Fetch groups a user is a member of"
      option :id, type: :string, required: true, desc: "User ID"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def groups
        client = W3cApi::Client.new
        groups = client.user_groups(options[:id])
        output_results(groups, options[:format])
      end

      desc "specifications", "Fetch specifications a user has contributed to"
      option :id, type: :string, required: true,
                  desc: "User ID (string or numeric)"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def specifications
        client = W3cApi::Client.new
        specifications = client.user_specifications(options[:id])
        output_results(specifications, options[:format])
      end

      desc "affiliations", "Fetch affiliations of a user"
      option :id, type: :string, required: true,
                  desc: "User ID (string or numeric)"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def affiliations
        client = W3cApi::Client.new
        affiliations = client.user_affiliations(options[:id])
        output_results(affiliations, options[:format])
      end

      desc "participations", "Fetch participations of a user"
      option :id, type: :string, required: true,
                  desc: "User ID (string or numeric)"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def participations
        client = W3cApi::Client.new
        participations = client.user_participations(options[:id])
        output_results(participations, options[:format])
      end

      desc "chair-of-groups", "Fetch groups a user chairs"
      option :id, type: :string, required: true,
                  desc: "User ID (string or numeric)"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def chair_of_groups
        client = W3cApi::Client.new
        groups = client.user_chair_of_groups(options[:id])
        output_results(groups, options[:format])
      end

      desc "team-contact-of-groups", "Fetch groups a user is a team contact of"
      option :id, type: :string, required: true,
                  desc: "User ID (string or numeric)"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def team_contact_of_groups
        client = W3cApi::Client.new
        groups = client.user_team_contact_of_groups(options[:id])
        output_results(groups, options[:format])
      end
    end
  end
end
