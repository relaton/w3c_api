# frozen_string_literal: true

require 'faraday'
require 'faraday/follow_redirects'
require 'json'

module W3c
  module Api
    class Error < StandardError; end
    class NotFoundError < Error; end
    class UnauthorizedError < Error; end
    class BadRequestError < Error; end
    class ServerError < Error; end

    class Client
      API_ENDPOINT = 'https://api.w3.org'

      attr_reader :last_response

      def initialize(options = {})
        @api_endpoint = options[:api_endpoint] || API_ENDPOINT
        @connection = create_connection
        @params_default = { page: 1, items: 3000 }
        @debug = !ENV['DEBUG_API'].nil?
      end

      # Specification methods

      def specifications(options = {})
        response = get('specifications', options.merge(@params_default))
        Models::Specifications.from_response(response['_links']['specifications'])
      end

      def specification(shortname, options = {})
        response = get("specifications/#{shortname}", options)
        Models::Specification.from_response(response)
      end

      def specification_versions(shortname, options = {})
        response = get("specifications/#{shortname}/versions", options)
        Models::SpecVersions.from_response(response['_links']['version-history'])
      end

      def specification_version(shortname, version, options = {})
        response = get("specifications/#{shortname}/versions/#{version}", options)
        Models::SpecVersion.from_response(response)
      end

      def specifications_by_status(status, options = {})
        response = get("specifications-by-status/#{status}", options.merge(@params_default))
        Models::Specifications.from_response(response['_links']['specifications'])
      end

      def specification_supersedes(shortname, options = {})
        response = get("specifications/#{shortname}/supersedes", options)
        Models::Specifications.from_response(response['_links']['specifications'])
      end

      def specification_superseded_by(shortname, options = {})
        response = get("specifications/#{shortname}/superseded", options)
        Models::Specifications.from_response(response['_links']['specifications'])
      end

      # Series methods

      def series(options = {})
        response = get('specification-series', options.merge(@params_default))
        Models::Series.from_response(response['_links']['specification-series'])
      end

      def series_by_shortname(shortname, options = {})
        response = get("specification-series/#{shortname}", options)
        Models::Serie.from_response(response)
      end

      def series_specifications(shortname, options = {})
        response = get("specification-series/#{shortname}/specifications", options.merge(@params_default))
        Models::Specifications.from_response(response['_links']['specifications'])
      end

      # Group methods

      def groups(options = {})
        response = get('groups', options)
        Models::Groups.from_response(response['_links']['groups'])
      end

      def group(id, options = {})
        response = get("groups/#{id}", options)
        Models::Group.from_response(response)
      end

      def group_specifications(id, options = {})
        response = get("groups/#{id}/specifications", options)
        Models::Specifications.from_response(response['_links']['specifications'])
      end

      def group_users(id, options = {})
        response = get("groups/#{id}/users", options)
        Models::Users.from_response(response['_links']['users'])
      end

      def group_charters(id, options = {})
        response = get("groups/#{id}/charters", options)
        Models::Charters.from_response(response['_links']['charters'])
      end

      def group_chairs(id, options = {})
        response = get("groups/#{id}/chairs", options)
        Models::Users.from_response(response['_links']['chairs'])
      rescue NotFoundError
        # Return empty users collection when endpoint not found
        Models::Users.from_response([])
      end

      def group_team_contacts(id, options = {})
        response = get("groups/#{id}/teamcontacts", options)
        Models::Users.from_response(response['_links']['team-contacts'])
      rescue NotFoundError
        # Return empty users collection when endpoint not found
        Models::Users.from_response([])
      end

      def group_participations(id, options = {})
        response = get("groups/#{id}/participations", options)
        Models::Participations.from_response(response['_links']['participations'])
      end

      # User methods

      def users(options = {})
        raise ArgumentError,
              'The W3C API does not support fetching all users. You must provide a specific user ID with the user method.'
      end

      def user(id, options = {})
        response = get("users/#{id}", options)
        Models::User.from_response(response)
      end

      def user_specifications(id, options = {})
        response = get("users/#{id}/specifications", options)
        Models::Specifications.from_response(response['_links']['specifications'])
      rescue NotFoundError
        # Return empty specifications collection when endpoint not found
        Models::Specifications.from_response([])
      end

      def user_groups(id, options = {})
        response = get("users/#{id}/groups", options)
        Models::Groups.from_response(response['_links']['groups'])
      end

      def user_affiliations(id, options = {})
        response = get("users/#{id}/affiliations", options)
        Models::Affiliations.from_response(response['_links']['affiliations'])
      rescue NotFoundError
        # Return empty affiliations collection when endpoint not found
        Models::Affiliations.from_response([])
      end

      def user_participations(id, options = {})
        response = get("users/#{id}/participations", options)
        Models::Participations.from_response(response['_links']['participations'])
      rescue NotFoundError
        # Return empty participations collection when endpoint not found
        Models::Participations.from_response([])
      end

      def user_chair_of_groups(id, options = {})
        response = get("users/#{id}/chair-of-groups", options)
        Models::Groups.from_response(response['_links']['groups'])
      rescue NotFoundError
        # Return empty groups collection when endpoint not found
        Models::Groups.from_response([])
      end

      def user_team_contact_of_groups(id, options = {})
        response = get("users/#{id}/team-contact-of-groups", options)
        Models::Groups.from_response(response['_links']['groups'])
      rescue NotFoundError
        # Return empty groups collection when endpoint not found
        Models::Groups.from_response([])
      end

      # Translation methods

      def translations(options = {})
        response = get('translations', options.merge(embed: true))
        Models::Translations.from_response(response['_links']['translations'])
      end

      def translation(id, options = {})
        response = get("translations/#{id}", options)
        Models::Translation.from_response(response)
      end

      # Affiliation methods

      def affiliations(options = {})
        response = get('affiliations', options.merge(@params_default))
        Models::Affiliations.from_response(response['_links']['affiliations'])
      end

      def affiliation(id, options = {})
        response = get("affiliations/#{id}", options)
        Models::Affiliation.from_response(response)
      end

      def affiliation_participants(id, options = {})
        response = get("affiliations/#{id}/participants", options)
        Models::Users.from_response(response['_links']['participants'])
      end

      def affiliation_participations(id, options = {})
        response = get("affiliations/#{id}/participations", options)
        Models::Participations.from_response(response['_links']['participations'])
      end

      # Ecosystem methods

      def ecosystems(options = {})
        response = get('ecosystems', options)
        Models::Ecosystems.from_response(response['_links']['ecosystems'])
      end

      def ecosystem(shortname, options = {})
        response = get("ecosystems/#{shortname}", options)
        Models::Ecosystem.from_response(response)
      end

      def ecosystem_groups(shortname, options = {})
        response = get("ecosystems/#{shortname}/groups", options)
        Models::Groups.from_response(response['_links']['groups'])
      end

      def ecosystem_evangelists(shortname, options = {})
        response = get("ecosystems/#{shortname}/evangelists", options)
        Models::Users.from_response(response['_links']['users'])
      end

      def ecosystem_member_organizations(shortname, options = {})
        response = get("ecosystems/#{shortname}/member-organizations", options)
        Models::Affiliations.from_response(response['_links']['affiliations'])
      end

      # Participation methods

      def participation(id, options = {})
        response = get("participations/#{id}", options)
        Models::Participation.from_response(response)
      end

      def participation_participants(id, options = {})
        response = get("participations/#{id}/participants", options)
        Models::Users.from_response(response['_links']['users'])
      end

      # Make the get method public for testing
      def get(url, params = {})
        @last_response = @connection.get(url, params)
        handle_response(@last_response, url)
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

      def handle_response(response, url)
        debug_log(response, url) if @debug

        case response.status
        when 200..299
          response.body
        when 400
          raise W3c::Api::BadRequestError, response_message(response)
        when 401
          raise W3c::Api::UnauthorizedError, response_message(response)
        when 404
          raise W3c::Api::NotFoundError, response_message(response)
        when 500..599
          raise W3c::Api::ServerError, response_message(response)
        else
          raise W3c::Api::Error, response_message(response)
        end
      end

      def debug_log(response, url)
        puts "\n===== DEBUG: W3C API REQUEST =====".blue if defined?(Rainbow)
        puts "\n===== DEBUG: W3C API REQUEST =====" unless defined?(Rainbow)
        puts "URL: #{url}"
        puts "Status: #{response.status}"

        # Format headers as JSON
        puts "\nHeaders:"
        headers_hash = response.headers.to_h
        puts JSON.pretty_generate(headers_hash)

        puts "\nResponse body:"
        if response.body.is_a?(Hash) || response.body.is_a?(Array)
          puts JSON.pretty_generate(response.body)
        else
          puts response.body.inspect
        end
        puts "===== END DEBUG OUTPUT =====\n"
      end

      def response_message(response)
        message = "Status: #{response.status}"
        message += ", Error: #{response.body['error']}" if response.body.is_a?(Hash) && response.body['error']
        message
      end
    end # End of Client class
  end # End of Api module
end # End of W3c module
