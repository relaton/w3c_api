# frozen_string_literal: true

require 'thor'
require_relative 'output_formatter'

module W3c
  module Api
    module Cli
      # Thor CLI command for group operations
      class Group < Thor
        include OutputFormatter

        desc 'fetch [OPTIONS]', 'Fetch groups'
        option :id, type: :numeric, desc: 'Group ID'
        option :format, type: :string, default: 'json', enum: %w[json yaml], desc: 'Output format'
        def fetch
          client = W3c::Api::Client.new

          groups = if options[:id]
                     # Single group wrapped in a collection
                     group = client.group(options[:id])
                     Models::Groups.new(groups: [group])
                   else
                     client.groups
                   end

          output_results(groups, options[:format])
        end

        desc 'users', 'Fetch users in a group'
        option :id, type: :numeric, required: true, desc: 'Group ID'
        option :format, type: :string, default: 'json', enum: %w[json yaml], desc: 'Output format'
        def users
          client = W3c::Api::Client.new
          users = client.group_users(options[:id])
          output_results(users, options[:format])
        end

        desc 'specifications', 'Fetch specifications produced by a group'
        option :id, type: :numeric, required: true, desc: 'Group ID'
        option :format, type: :string, default: 'json', enum: %w[json yaml], desc: 'Output format'
        def specifications
          client = W3c::Api::Client.new
          specifications = client.group_specifications(options[:id])
          output_results(specifications, options[:format])
        end

        desc 'charters', 'Fetch charters of a group'
        option :id, type: :numeric, required: true, desc: 'Group ID'
        option :format, type: :string, default: 'json', enum: %w[json yaml], desc: 'Output format'
        def charters
          client = W3c::Api::Client.new
          charters = client.group_charters(options[:id])
          output_results(charters, options[:format])
        end
      end
    end
  end
end
