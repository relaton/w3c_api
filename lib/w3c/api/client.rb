# frozen_string_literal: true

require 'faraday'
require 'faraday/follow_redirects'
require 'json'

module W3c
  module Api
    class Client
      API_ENDPOINT = 'https://api.w3.org'

      attr_reader :last_response

      def initialize(options = {})
        @api_endpoint = options[:api_endpoint] || API_ENDPOINT
        @connection = create_connection
      end

      # Specification methods

      def specifications(options = {})
        response = get('specifications', options)
        specs = response.map { |spec| Models::Specification.from_response(spec) }
        Models::Specifications.new(specifications: specs)
      end

      def specification(shortname, options = {})
        response = get("specifications/#{shortname}", options)
        Models::Specification.from_response(response)
      end

      def specification_versions(shortname, options = {})
        response = get("specifications/#{shortname}/versions", options)
        versions = response.map { |version| Models::SpecVersion.from_response(version) }
        Models::SpecVersions.new(spec_versions: versions)
      end

      # Group methods

      def groups(options = {})
        response = get('groups', options)
        groups_list = response.map { |group| Models::Group.from_response(group) }
        Models::Groups.new(groups: groups_list)
      end

      def group(id, options = {})
        response = get("groups/#{id}", options)
        Models::Group.from_response(response)
      end

      def group_specifications(id, options = {})
        response = get("groups/#{id}/specifications", options)
        specs = response.map { |spec| Models::Specification.from_response(spec) }
        Models::Specifications.new(specifications: specs)
      end

      def group_users(id, options = {})
        response = get("groups/#{id}/users", options)
        users_list = response.map { |user| Models::User.from_response(user) }
        Models::Users.new(users: users_list)
      end

      def group_charters(id, options = {})
        response = get("groups/#{id}/charters", options)
        charters_list = response.map { |charter| Models::Charter.from_response(charter) }
        Models::Charters.new(charters: charters_list)
      end

      # User methods

      def users(options = {})
        response = get('users', options)
        users_list = response.map { |user| Models::User.from_response(user) }
        Models::Users.new(users: users_list)
      end

      def user(id, options = {})
        response = get("users/#{id}", options)
        Models::User.from_response(response)
      end

      def user_specifications(id, options = {})
        response = get("users/#{id}/specifications", options)
        specs = response.map { |spec| Models::Specification.from_response(spec) }
        Models::Specifications.new(specifications: specs)
      end

      def user_groups(id, options = {})
        response = get("users/#{id}/groups", options)
        groups_list = response.map { |group| Models::Group.from_response(group) }
        Models::Groups.new(groups: groups_list)
      end

      # Translation methods

      def translations(options = {})
        response = get('translations', options)
        translations_list = response.map { |translation| Models::Translation.from_response(translation) }
        Models::Translations.new(translations: translations_list)
      end

      def translation(uri, options = {})
        response = get("translations/#{uri}", options)
        Models::Translation.from_response(response)
      end

      # Contribution methods

      def contributions(options = {})
        response = get('contributions', options)
        # NOTE: No Contributions collection model created yet
        response.map { |contribution| Models::Contribution.from_response(contribution) }
      end

      # Ecosystem methods

      def ecosystems(options = {})
        response = get('ecosystems', options)
        ecosystems_list = response.map { |ecosystem| Models::Ecosystem.from_response(ecosystem) }
        Models::Ecosystems.new(ecosystems: ecosystems_list)
      end

      def ecosystem(shortname, options = {})
        response = get("ecosystems/#{shortname}", options)
        Models::Ecosystem.from_response(response)
      end

      # Service methods

      def services(options = {})
        response = get('services', options)
        services_list = response.map { |service| Models::Service.from_response(service) }
        Models::Services.new(services: services_list)
      end

      def service(type, options = {})
        response = get("services/#{type}", options)
        Models::Service.from_response(response)
      end

      # Make the get method public for testing
      def get(url, params = {})
        @last_response = @connection.get(url, params)
        handle_response(@last_response)
      end

      private

      def create_connection
        Faraday.new(url: @api_endpoint) do |conn|
          conn.use Faraday::FollowRedirects::Middleware
          conn.request :json
          conn.response :json, content_type: /\bjson$/
          conn.adapter Faraday.default_adapter
        end
      end

      def handle_response(response)
        case response.status
        when 200..299
          response.body
        when 400
          raise BadRequestError, response_message(response)
        when 401
          raise UnauthorizedError, response_message(response)
        when 404
          raise NotFoundError, response_message(response)
        when 500..599
          raise ServerError, response_message(response)
        else
          raise Error, response_message(response)
        end
      end

      def response_message(response)
        message = "Status: #{response.status}"
        message += ", Error: #{response.body['error']}" if response.body.is_a?(Hash) && response.body['error']
        message
      end
    end
  end
end
