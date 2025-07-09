# frozen_string_literal: true

require "thor"
require_relative "output_formatter"
require_relative "../client"

module W3cApi
  module Commands
    # Thor CLI command for ecosystem operations
    class Ecosystem < Thor
      include OutputFormatter

      desc "fetch [OPTIONS]", "Fetch ecosystems"
      option :shortname, type: :string, desc: "Ecosystem shortname"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def fetch
        client = W3cApi::Client.new

        ecosystems = if options[:shortname]
                       # Single ecosystem
                       client.ecosystem(options[:shortname])
                     else
                       client.ecosystems
                     end

        output_results(ecosystems, options[:format])
      end

      desc "groups", "Fetch groups in an ecosystem"
      option :shortname, type: :string, required: true,
                         desc: "Ecosystem shortname"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def groups
        client = W3cApi::Client.new
        groups = client.ecosystem_groups(options[:shortname])
        output_results(groups, options[:format])
      end

      desc "evangelists", "Fetch evangelists of an ecosystem"
      option :shortname, type: :string, required: true,
                         desc: "Ecosystem shortname"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def evangelists
        client = W3cApi::Client.new
        evangelists = client.ecosystem_evangelists(options[:shortname])
        output_results(evangelists, options[:format])
      end

      desc "member-organizations", "Fetch member organizations of an ecosystem"
      option :shortname, type: :string, required: true,
                         desc: "Ecosystem shortname"
      option :format, type: :string, default: "yaml", enum: %w[json yaml],
                      desc: "Output format"
      def member_organizations
        client = W3cApi::Client.new
        organizations = client.ecosystem_member_organizations(options[:shortname])
        output_results(organizations, options[:format])
      end
    end
  end
end
