# frozen_string_literal: true

require "singleton"
require "lutaml/hal"
require_relative "models"

module W3cApi
  # Simple parameter class to satisfy lutaml-hal validation requirements
  class SimpleParameter
    attr_reader :name, :location, :required, :default_value

    def initialize(name, location: :path, required: false, default_value: nil)
      @name = name.to_s
      @location = location
      @required = required
      @default_value = default_value
    end

    def validate!
      # Simple validation - just ensure name is present
      if @name.nil? || @name.empty?
        raise ArgumentError,
              "Parameter name cannot be empty"
      end
    end

    def path_parameter?
      @location == :path
    end

    def query_parameter?
      @location == :query
    end

    def validate_value(value)
      # Simple validation - accept any non-nil value
      !value.nil?
    end
  end

  class Hal
    include Singleton

    API_URL = "https://api.w3.org/"

    def initialize
      # Don't call setup here - it will be called when register is first accessed
    end

    def client
      @client ||= Lutaml::Hal::Client.new(
        api_url: API_URL,
        rate_limiting: rate_limiting_options,
      )
    end

    # Configure rate limiting options
    def rate_limiting_options
      @rate_limiting_options ||= {
        enabled: true,
        max_retries: 5,
        base_delay: 0.1,
        max_delay: 10.0,
        backoff_factor: 1.5,
      }
    end

    # Set rate limiting options
    def configure_rate_limiting(options = {})
      @rate_limiting_options = rate_limiting_options.merge(options)
      # Reset client to pick up new options
      @client = nil
    end

    # Disable rate limiting
    def disable_rate_limiting
      configure_rate_limiting(enabled: false)
    end

    # Enable rate limiting
    def enable_rate_limiting
      configure_rate_limiting(enabled: true)
    end

    def register
      return @register if @register

      @register = Lutaml::Hal::ModelRegister.new(name: :w3c_api, client: client)
      Lutaml::Hal::GlobalRegister.instance.register(:w3c_api, @register)

      # Re-run setup to register all endpoints with the new register
      setup

      @register
    end

    def reset_register
      @register = nil
    end

    private

    # Common pagination parameters (simplified without EndpointParameter)
    def pagination_parameters
      [
        SimpleParameter.new("page", location: :query),
        SimpleParameter.new("items", location: :query),
      ]
    end

    # Parameters for endpoints with embed support (simplified without EndpointParameter)
    def embed_parameters
      [
        SimpleParameter.new("embed", location: :query),
      ] + pagination_parameters
    end

    # Helper methods for common parameter types (using SimpleParameter)
    def string_path_param(name, _description = nil)
      SimpleParameter.new(name, location: :path)
    end

    def integer_path_param(name, _description = nil)
      SimpleParameter.new(name, location: :path)
    end

    def string_query_param(name, _description = nil, required: false)
      SimpleParameter.new(name, location: :query, required: required)
    end

    # Helper method to add index endpoints with pagination
    def add_index_endpoint(id, url, model, parameters = pagination_parameters)
      register.add_endpoint(
        id: id,
        type: :index,
        url: url,
        model: model,
        parameters: parameters,
      )
    end

    # Helper method to add resource endpoints
    def add_resource_endpoint(id, url, model, parameters = [])
      register.add_endpoint(
        id: id,
        type: :resource,
        url: url,
        model: model,
        parameters: parameters,
      )
    end

    # Helper method to add endpoints with path parameters
    def add_endpoint_with_path_params(id, type, url, model, path_params = [],
query_params = [])
      parameters = (path_params + query_params).compact
      register.add_endpoint(
        id: id,
        type: type,
        url: url,
        model: model,
        parameters: parameters,
      )
    end

    def setup
      # Specification endpoints with embed support
      add_index_endpoint(
        :specification_index,
        "/specifications",
        Models::SpecificationIndex,
        embed_parameters,
      )

      # Specification by status endpoint
      add_endpoint_with_path_params(
        :specification_by_status_index,
        :index,
        "/specifications",
        Models::SpecificationIndex,
        [],
        [string_query_param("status", required: true)] + pagination_parameters,
      )
      add_endpoint_with_path_params(
        :specification_resource,
        :resource,
        "/specifications/{shortname}",
        Models::Specification,
        [string_path_param("shortname")],
      )

      # Specification version endpoints
      add_endpoint_with_path_params(
        :specification_resource_version_index,
        :index,
        "/specifications/{shortname}/versions",
        Models::SpecVersionIndex,
        [string_path_param("shortname")],
        pagination_parameters,
      )
      add_endpoint_with_path_params(
        :specification_resource_version_resource,
        :resource,
        "/specifications/{shortname}/versions/{version}",
        Models::SpecVersion,
        [
          string_path_param("shortname"),
          string_path_param("version"),
        ],
      )

      # Specification version editors and deliverers
      add_endpoint_with_path_params(
        :specification_version_editors_index,
        :index,
        "/specifications/{shortname}/versions/{version}/editors",
        Models::EditorIndex,
        [
          string_path_param("shortname"),
          string_path_param("version"),
        ],
        pagination_parameters,
      )
      add_endpoint_with_path_params(
        :specification_version_deliverers_index,
        :index,
        "/specifications/{shortname}/versions/{version}/deliverers",
        Models::DelivererIndex,
        [
          string_path_param("shortname"),
          string_path_param("version"),
        ],
        pagination_parameters,
      )

      # Specification version predecessors and successors
      add_endpoint_with_path_params(
        :specification_version_predecessors_index,
        :index,
        "/specifications/{shortname}/versions/{version}/predecessors",
        Models::SpecVersionPredecessorIndex,
        [
          string_path_param("shortname"),
          string_path_param("version"),
        ],
        pagination_parameters,
      )
      add_endpoint_with_path_params(
        :specification_version_successors_index,
        :index,
        "/specifications/{shortname}/versions/{version}/successors",
        Models::SpecVersionSuccessorIndex,
        [
          string_path_param("shortname"),
          string_path_param("version"),
        ],
        pagination_parameters,
      )

      # Specification related endpoints
      %w[supersedes superseded_by editors deliverers].each do |relation|
        add_endpoint_with_path_params(
          :"specification_#{relation}_index",
          :index,
          "/specifications/{shortname}/#{relation.tr('_', '-')}",
          relation.include?("editor") ? Models::UserIndex : Models::GroupIndex,
          [string_path_param("shortname")],
          pagination_parameters,
        )
      end

      # TODO: Why is this endpoint needed? There already is /specifications/{shortname}...
      # register.add_endpoint(
      #   id: :specification_by_shortname_index,
      #   type: :index,
      #   url: '/specifications-by-shortname/{shortname}',
      #   model: Models::SpecificationIndex
      # )

      # Series endpoints with embed support
      add_index_endpoint(
        :serie_index,
        "/specification-series",
        Models::SerieIndex,
        embed_parameters,
      )
      add_endpoint_with_path_params(
        :serie_resource,
        :resource,
        "/specification-series/{shortname}",
        Models::Serie,
        [string_path_param("shortname")],
      )
      add_endpoint_with_path_params(
        :serie_specification_resource,
        :index,
        "/specification-series/{shortname}/specifications",
        Models::SpecificationIndex,
        [string_path_param("shortname")],
        pagination_parameters,
      )

      # Group endpoints with embed support
      add_index_endpoint(
        :group_index,
        "/groups",
        Models::GroupIndex,
        embed_parameters,
      )
      add_endpoint_with_path_params(
        :group_resource,
        :resource,
        "/groups/{id}",
        Models::Group,
        [integer_path_param("id")],
      )
      add_endpoint_with_path_params(
        :group_by_type_shortname_resource,
        :resource,
        "/groups/{type}/{shortname}",
        Models::Group,
        [
          string_path_param("type"),
          string_path_param("shortname"),
        ],
      )
      add_endpoint_with_path_params(
        :group_by_type_index,
        :index,
        "/groups/{type}",
        Models::GroupIndex,
        [string_path_param("type")],
        pagination_parameters,
      )
      # Group nested endpoints
      add_endpoint_with_path_params(
        :group_specifications_index,
        :index,
        "/groups/{id}/specifications",
        Models::SpecificationIndex,
        [integer_path_param("id")],
        pagination_parameters,
      )
      add_endpoint_with_path_params(
        :group_users_index,
        :index,
        "/groups/{id}/users",
        Models::UserIndex,
        [integer_path_param("id")],
        pagination_parameters,
      )
      add_endpoint_with_path_params(
        :group_charters_index,
        :index,
        "/groups/{id}/charters",
        Models::CharterIndex,
        [integer_path_param("id")],
        pagination_parameters,
      )
      add_endpoint_with_path_params(
        :group_chairs_index,
        :index,
        "/groups/{id}/chairs",
        Models::ChairIndex,
        [integer_path_param("id")],
        pagination_parameters,
      )
      add_endpoint_with_path_params(
        :group_team_contacts_index,
        :index,
        "/groups/{id}/teamcontacts",
        Models::TeamContactIndex,
        [integer_path_param("id")],
        pagination_parameters,
      )
      add_endpoint_with_path_params(
        :group_participations_index,
        :index,
        "/groups/{id}/participations",
        Models::ParticipationIndex,
        [integer_path_param("id")],
        pagination_parameters,
      )

      # Translation endpoints
      add_index_endpoint(
        :translation_index,
        "/translations",
        Models::TranslationIndex,
      )
      add_endpoint_with_path_params(
        :translation_resource,
        :resource,
        "/translations/{id}",
        Models::Translation,
        [integer_path_param("id")],
      )

      # User endpoints
      # NOTE: This endpoint doesn't exist, just here for reference.
      # register.add_endpoint(
      #   id: :user_index,
      #   type: :index,
      #   url: '/users',
      #   model: Models::UserIndex
      # )
      add_endpoint_with_path_params(
        :user_resource,
        :resource,
        "/users/{hash}",
        Models::User,
        [string_path_param("hash")],
      )

      # User nested endpoints
      add_endpoint_with_path_params(
        :user_groups_index,
        :index,
        "/users/{hash}/groups",
        Models::GroupIndex,
        [string_path_param("hash")],
        pagination_parameters,
      )
      add_endpoint_with_path_params(
        :user_affiliations_index,
        :index,
        "/users/{hash}/affiliations",
        Models::AffiliationIndex,
        [string_path_param("hash")],
        pagination_parameters,
      )
      add_endpoint_with_path_params(
        :user_participations_index,
        :index,
        "/users/{hash}/participations",
        Models::ParticipationIndex,
        [string_path_param("hash")],
        pagination_parameters,
      )
      add_endpoint_with_path_params(
        :user_chair_of_groups_index,
        :index,
        "/users/{hash}/chair-of-groups",
        Models::GroupIndex,
        [string_path_param("hash")],
        pagination_parameters,
      )
      add_endpoint_with_path_params(
        :user_team_contact_of_groups_index,
        :index,
        "/users/{hash}/team-contact-of-groups",
        Models::GroupIndex,
        [string_path_param("hash")],
        pagination_parameters,
      )
      add_endpoint_with_path_params(
        :user_specifications_index,
        :index,
        "/users/{hash}/specifications",
        Models::SpecificationIndex,
        [string_path_param("hash")],
        pagination_parameters,
      )

      # Affiliation endpoints
      add_index_endpoint(
        :affiliation_index,
        "/affiliations",
        Models::AffiliationIndex,
      )
      add_endpoint_with_path_params(
        :affiliation_resource,
        :resource,
        "/affiliations/{id}",
        Models::Affiliation,
        [integer_path_param("id")],
      )

      # Affiliation nested endpoints
      add_endpoint_with_path_params(
        :affiliation_participants_index,
        :index,
        "/affiliations/{id}/participants",
        Models::ParticipantIndex,
        [integer_path_param("id")],
        pagination_parameters,
      )
      add_endpoint_with_path_params(
        :affiliation_participations_index,
        :index,
        "/affiliations/{id}/participations",
        Models::ParticipationIndex,
        [integer_path_param("id")],
        pagination_parameters,
      )

      # Ecosystem endpoints
      add_index_endpoint(
        :ecosystem_index,
        "/ecosystems",
        Models::EcosystemIndex,
      )
      add_endpoint_with_path_params(
        :ecosystem_resource,
        :resource,
        "/ecosystems/{shortname}",
        Models::Ecosystem,
        [string_path_param("shortname")],
      )

      # Ecosystem nested endpoints
      add_endpoint_with_path_params(
        :ecosystem_groups_index,
        :index,
        "/ecosystems/{shortname}/groups",
        Models::GroupIndex,
        [string_path_param("shortname")],
        pagination_parameters,
      )
      add_endpoint_with_path_params(
        :ecosystem_evangelists_index,
        :index,
        "/ecosystems/{shortname}/evangelists",
        Models::EvangelistIndex,
        [string_path_param("shortname")],
        pagination_parameters,
      )
      add_endpoint_with_path_params(
        :ecosystem_member_organizations_index,
        :index,
        "/ecosystems/{shortname}/member-organizations",
        Models::AffiliationIndex,
        [string_path_param("shortname")],
        pagination_parameters,
      )

      # Participation endpoints
      add_endpoint_with_path_params(
        :participation_resource,
        :resource,
        "/participations/{id}",
        Models::Participation,
        [integer_path_param("id")],
      )
      add_endpoint_with_path_params(
        :participation_participants_index,
        :index,
        "/participations/{id}/participants",
        Models::ParticipantIndex,
        [integer_path_param("id")],
        pagination_parameters,
      )
    end
  end
end
