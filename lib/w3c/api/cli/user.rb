# frozen_string_literal: true

require 'thor'
require_relative 'output_formatter'

module W3c
  module Api
    module Cli
      # Thor CLI command for user operations
      class User < Thor
        include OutputFormatter

        desc 'fetch [OPTIONS]', 'Fetch users'
        option :id, type: :numeric, desc: 'User ID'
        option :format, type: :string, default: 'json', enum: %w[json yaml], desc: 'Output format'
        def fetch
          client = W3c::Api::Client.new

          users = if options[:id]
                    # Single user wrapped in a collection
                    user = client.user(options[:id])
                    Models::Users.new(users: [user])
                  else
                    client.users
                  end

          output_results(users, options[:format])
        end

        desc 'groups', 'Fetch groups a user is a member of'
        option :id, type: :numeric, required: true, desc: 'User ID'
        option :format, type: :string, default: 'json', enum: %w[json yaml], desc: 'Output format'
        def groups
          client = W3c::Api::Client.new
          groups = client.user_groups(options[:id])
          output_results(groups, options[:format])
        end

        desc 'specifications', 'Fetch specifications a user has contributed to'
        option :id, type: :numeric, required: true, desc: 'User ID'
        option :format, type: :string, default: 'json', enum: %w[json yaml], desc: 'Output format'
        def specifications
          client = W3c::Api::Client.new
          specifications = client.user_specifications(options[:id])
          output_results(specifications, options[:format])
        end
      end
    end
  end
end
