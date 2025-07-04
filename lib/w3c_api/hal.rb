# frozen_string_literal: true

require 'singleton'
require_relative 'models'

module W3cApi
  class Hal
    include Singleton

    API_URL = 'https://api.w3.org/'

    def initialize
      setup
    end

    def client
      @client ||= Lutaml::Hal::Client.new(api_url: API_URL)
    end

    def register
      return @register if @register

      @register = Lutaml::Hal::ModelRegister.new(name: :w3c_api, client: client)
      Lutaml::Hal::GlobalRegister.instance.register(
        :w3c_api, @register
      )
      @register
    end

    private

    # Common pagination query parameters
    PAGINATION_PARAMS = { 'page' => '{page}',
                          'items' => '{items}' }.freeze

    # Helper method to add index endpoints with pagination
    def add_index_endpoint(id, url, model, query_params = PAGINATION_PARAMS)
      register.add_endpoint(
        id: id,
        type: :index,
        url: url,
        model: model,
        query_params: query_params
      )
    end

    # Helper method to add resource endpoints
    def add_resource_endpoint(id, url, model)
      register.add_endpoint(
        id: id,
        type: :resource,
        url: url,
        model: model
      )
    end

    # Helper method to add nested index endpoints
    def add_nested_index_endpoints(parent_resource, parent_id_param, endpoints)
      endpoints.each do |endpoint|
        add_index_endpoint(
          :"#{parent_resource}_#{endpoint[:name]}_index",
          "/#{parent_resource}/#{parent_id_param}/#{endpoint[:path]}",
          endpoint[:model]
        )
      end
    end

    # Helper method to add individual nested endpoints
    def add_nested_endpoint(parent_resource, parent_id_param, endpoint_name, endpoint_path, model)
      add_index_endpoint(
        :"#{parent_resource}_#{endpoint_name}_index",
        "/#{parent_resource}/#{parent_id_param}/#{endpoint_path}",
        model
      )
    end

    def setup
      # Specification endpoints
      add_index_endpoint(
        :specification_index,
        '/specifications',
        Models::SpecificationIndex
      )
      add_resource_endpoint(
        :specification_resource,
        '/specifications/{shortname}',
        Models::Specification
      )
      add_index_endpoint(
        :specification_by_status_index,
        '/specifications',
        Models::SpecificationIndex,
        { 'status' => '{status}', **PAGINATION_PARAMS }
      )

      # Specification version endpoints
      add_index_endpoint(
        :specification_resource_version_index,
        '/specifications/{shortname}/versions',
        Models::SpecVersionIndex
      )
      add_resource_endpoint(
        :specification_resource_version_resource,
        '/specifications/{shortname}/versions/{version}',
        Models::SpecVersion
      )

      # Specification version editors and deliverers
      add_index_endpoint(
        :specification_version_editors_index,
        '/specifications/{shortname}/versions/{version}/editors',
        Models::EditorIndex
      )
      add_index_endpoint(
        :specification_version_deliverers_index,
        '/specifications/{shortname}/versions/{version}/deliverers',
        Models::DelivererIndex
      )

      # Specification related endpoints
      %w[supersedes superseded_by editors deliverers].each do |relation|
        add_index_endpoint(
          :"specification_#{relation}_index",
          "/specifications/{shortname}/#{relation.tr('_', '-')}",
          relation.include?('editor') ? Models::UserIndex : Models::GroupIndex
        )
      end

      # TODO: Why is this endpoint needed? There already is /specifications/{shortname}...
      # register.add_endpoint(
      #   id: :specification_by_shortname_index,
      #   type: :index,
      #   url: '/specifications-by-shortname/{shortname}',
      #   model: Models::SpecificationIndex
      # )

      # Series endpoints
      add_index_endpoint(
        :serie_index,
        '/specification-series',
        Models::SerieIndex
      )
      add_resource_endpoint(
        :serie_resource,
        '/specification-series/{shortname}',
        Models::Serie
      )
      add_index_endpoint(
        :serie_specification_resource,
        '/specification-series/{shortname}/specifications',
        Models::SpecificationIndex
      )

      # Group endpoints
      add_index_endpoint(
        :group_index,
        '/groups',
        Models::GroupIndex
      )
      add_resource_endpoint(
        :group_resource,
        '/groups/{id}',
        Models::Group
      )
      # Group nested endpoints
      add_index_endpoint(
        :group_specifications_index,
        '/groups/{id}/specifications',
        Models::SpecificationIndex
      )
      add_index_endpoint(
        :group_users_index,
        '/groups/{id}/users',
        Models::UserIndex
      )
      add_index_endpoint(
        :group_charters_index,
        '/groups/{id}/charters',
        Models::CharterIndex
      )
      add_index_endpoint(
        :group_chairs_index,
        '/groups/{id}/chairs',
        Models::ChairIndex
      )
      add_index_endpoint(
        :group_team_contacts_index,
        '/groups/{id}/teamcontacts',
        Models::TeamContactIndex
      )
      add_index_endpoint(
        :group_participations_index,
        '/groups/{id}/participations',
        Models::ParticipationIndex
      )

      # Translation endpoints
      add_index_endpoint(
        :translation_index,
        '/translations',
        Models::TranslationIndex
      )
      add_resource_endpoint(
        :translation_resource,
        '/translations/{id}',
        Models::Translation
      )

      # User endpoints
      # NOTE: This endpoint doesn't exist, just here for reference.
      # register.add_endpoint(
      #   id: :user_index,
      #   type: :index,
      #   url: '/users',
      #   model: Models::UserIndex
      # )
      add_resource_endpoint(
        :user_resource,
        '/users/{hash}',
        Models::User
      )

      # User nested endpoints
      add_index_endpoint(
        :user_groups_index,
        '/users/{hash}/groups',
        Models::GroupIndex
      )
      add_index_endpoint(
        :user_affiliations_index,
        '/users/{hash}/affiliations',
        Models::AffiliationIndex
      )
      add_index_endpoint(
        :user_participations_index,
        '/users/{hash}/participations',
        Models::ParticipationIndex
      )
      add_index_endpoint(
        :user_chair_of_groups_index,
        '/users/{hash}/chair-of-groups',
        Models::GroupIndex
      )
      add_index_endpoint(
        :user_team_contact_of_groups_index,
        '/users/{hash}/team-contact-of-groups',
        Models::GroupIndex
      )
      add_index_endpoint(
        :user_specifications_index,
        '/users/{hash}/specifications',
        Models::SpecificationIndex
      )

      # Affiliation endpoints
      add_index_endpoint(
        :affiliation_index,
        '/affiliations',
        Models::AffiliationIndex
      )
      add_resource_endpoint(
        :affiliation_resource,
        '/affiliations/{id}',
        Models::Affiliation
      )

      # Affiliation nested endpoints
      add_index_endpoint(
        :affiliation_participants_index,
        '/affiliations/{id}/participants',
        Models::ParticipantIndex
      )
      add_index_endpoint(
        :affiliation_participations_index,
        '/affiliations/{id}/participations',
        Models::ParticipationIndex
      )

      # Ecosystem endpoints
      add_index_endpoint(
        :ecosystem_index,
        '/ecosystems',
        Models::EcosystemIndex
      )
      add_resource_endpoint(
        :ecosystem_resource,
        '/ecosystems/{shortname}',
        Models::Ecosystem
      )

      # Ecosystem nested endpoints
      add_index_endpoint(
        :ecosystem_groups_index,
        '/ecosystems/{shortname}/groups',
        Models::GroupIndex
      )
      add_index_endpoint(
        :ecosystem_evangelists_index,
        '/ecosystems/{shortname}/evangelists',
        Models::EvangelistIndex
      )
      add_index_endpoint(
        :ecosystem_member_organizations_index,
        '/ecosystems/{shortname}/member-organizations',
        Models::AffiliationIndex
      )

      # Participation endpoints
      add_resource_endpoint(
        :participation_resource,
        '/participations/{id}',
        Models::Participation
      )
      add_index_endpoint(
        :participation_participants_index,
        '/participations/{id}/participants',
        Models::ParticipantIndex
      )
    end
  end
end
