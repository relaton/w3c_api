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
      register.add_endpoint(id: id, type: :resource, url: url, model: model)
    end

    # Helper method to add nested index endpoints for a parent resource
    def add_nested_index_endpoints(parent, parent_id_param, nested_configs)
      nested_configs.each do |config|
        # Convert plural parent to singular for endpoint naming
        singular_parent = parent.end_with?('s') ? parent[0..-2] : parent
        id = "#{singular_parent}_#{config[:name]}_index".to_sym
        url = "/#{parent}/#{parent_id_param}/#{config[:path]}"
        add_index_endpoint(id, url, config[:model])
      end
    end

    def setup
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

      # register.add_endpoint(
      #   id: :charter_resource,
      #   type: :resource,
      #   url: '/charters/{id}',
      #   model: Models::Charter
      # )

      # Ecosystem endpoints
      add_index_endpoint(
        :ecosystem_index,
        '/ecosystems',
        Models::EcosystemIndex
      )
      add_resource_endpoint(
        :ecosystem_resource,
        '/ecosystems/{id}',
        Models::Ecosystem
      )
      add_index_endpoint(
        :ecosystem_evangelists_index,
        '/ecosystems/{shortname}/evangelists',
        Models::EvangelistIndex
      )
      add_index_endpoint(
        :ecosystem_groups_index,
        '/ecosystems/{shortname}/groups',
        Models::GroupIndex
      )
      add_index_endpoint(
        :ecosystem_member_organizations_index,
        '/ecosystems/{shortname}/member-organizations',
        Models::AffiliationIndex
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
      add_nested_index_endpoints(
        'groups',
        '{id}', [
          { name: 'specifications', path: 'specifications',
            model: Models::SpecificationIndex },
          { name: 'charters', path: 'charters',
            model: Models::CharterIndex },
          { name: 'users', path: 'users',
            model: Models::UserIndex },
          { name: 'chairs', path: 'chairs',
            model: Models::ChairIndex },
          { name: 'team_contacts', path: 'teamcontacts',
            model: Models::TeamContactIndex },
          { name: 'participations', path: 'participations',
            model: Models::ParticipationIndex }
        ]
      )

      # Participation endpoints
      # register.add_endpoint(
      #   id: :participation_index,
      #   type: :index,
      #   url: '/participations',
      #   model: Models::ParticipationIndex
      # )

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

      # Serie endpoints
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
        :specification_resource_version_index,
        '/specifications/{shortname}/versions',
        Models::SpecVersionIndex
      )
      add_resource_endpoint(
        :specification_resource_version_resource,
        '/specifications/{shortname}/versions/{version}',
        Models::SpecVersion
      )
      add_index_endpoint(
        :specification_version_predecessors_index,
        '/specifications/{shortname}/versions/{version}/predecessors',
        Models::SpecVersionIndex
      )
      add_index_endpoint(
        :specification_version_successors_index,
        '/specifications/{shortname}/versions/{version}/successors',
        Models::SpecVersionIndex
      )
      add_index_endpoint(
        :specification_by_status_index,
        '/specifications-by-status/{status}',
        Models::SpecificationIndex
      )
      add_index_endpoint(
        :specification_supersedes_index,
        '/specifications/{shortname}/supersedes',
        Models::SpecificationIndex
      )
      add_index_endpoint(
        :specification_superseded_by_index,
        '/specifications/{shortname}/superseded',
        Models::SpecificationIndex
      )
      add_index_endpoint(
        :specification_version_editors_index,
        '/specifications/{shortname}/version/{version}/editors',
        Models::UserIndex
      )
      add_index_endpoint(
        :specification_version_deliverers_index,
        '/specifications/{shortname}/version/{version}/deliverers',
        Models::UserIndex
      )

      # TODO: Why is this endpoint needed? There already is /specifications/{shortname}...
      # register.add_endpoint(
      #   id: :specification_by_shortname_index,
      #   type: :index,
      #   url: '/specifications-by-shortname/{shortname}',
      #   model: Models::SpecificationIndex
      # )

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
      add_nested_index_endpoints(
        'users',
        '{hash}', [
          { name: 'groups', path: 'groups',
            model: Models::GroupIndex },
          { name: 'affiliations', path: 'affiliations',
            model: Models::AffiliationIndex },
          { name: 'participations', path: 'participations',
            model: Models::ParticipationIndex },
          { name: 'chair_of_groups', path: 'chair-of-groups',
            model: Models::GroupIndex },
          { name: 'team_contact_of_groups', path: 'team-contact-of-groups',
            model: Models::GroupIndex },
          { name: 'specifications', path: 'specifications',
            model: Models::SpecificationIndex }
        ]
      )
    end
  end
end
