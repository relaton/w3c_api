require 'singleton'
require_relative 'models'

module W3cApi
  class Hal
    include Singleton

    def initialize
      setup
    end

    def client
      @client ||= Lutaml::Hal::Client.new(api_url: 'https://api.w3.org/')
    end

    def register
      return @register if @register

      @register = Lutaml::Hal::ModelRegister.new(name: :w3c_api, client: client)
      Lutaml::Hal::GlobalRegister.instance.register(:w3c_api, @register)
      @register
    end

    def setup
      register.add_endpoint(id: :affiliation_index, type: :index, url: '/affiliations', model: Models::AffiliationIndex)
      register.add_endpoint(id: :affiliation_resource, type: :resource, url: '/affiliations/{id}',
                            model: Models::Affiliation)
      register.add_endpoint(id: :affiliation_participants_index, type: :index, url: '/affiliations/{id}/participants',
                            model: Models::ParticipantIndex)
      register.add_endpoint(id: :affiliation_participations_index, type: :index, url: '/affiliations/{id}/participations',
                            model: Models::ParticipationIndex)

      # register.add_endpoint(id: :charter_resource, type: :resource, url: '/charters/{id}', model: Models::Charter)

      register.add_endpoint(id: :ecosystem_index, type: :index, url: '/ecosystems', model: Models::EcosystemIndex)
      register.add_endpoint(id: :ecosystem_resource, type: :resource, url: '/ecosystems/{id}', model: Models::Ecosystem)
      register.add_endpoint(id: :ecosystem_evangelists_index, type: :index, url: '/ecosystems/{shortname}/evangelists',
                            model: Models::EvangelistIndex)
      register.add_endpoint(id: :ecosystem_groups_index, type: :index, url: '/ecosystems/{shortname}/groups',
                            model: Models::GroupIndex)
      register.add_endpoint(id: :ecosystem_member_organizations_index, type: :index, url: '/ecosystems/{shortname}/member-organizations',
                            model: Models::AffiliationIndex)

      register.add_endpoint(id: :group_index, type: :index, url: '/groups', model: Models::GroupIndex)
      register.add_endpoint(id: :group_resource, type: :resource, url: '/groups/{id}', model: Models::Group)
      register.add_endpoint(id: :group_specifications_index, type: :index, url: '/groups/{id}/specifications',
                            model: Models::SpecificationIndex)
      register.add_endpoint(id: :group_charters_index, type: :index, url: '/groups/{id}/charters',
                            model: Models::CharterIndex)
      register.add_endpoint(id: :group_users_index, type: :index, url: '/groups/{id}/users',
                            model: Models::UserIndex)
      register.add_endpoint(id: :group_chairs_index, type: :index, url: '/groups/{id}/chairs',
                            model: Models::ChairIndex)
      register.add_endpoint(id: :group_team_contacts_index, type: :index, url: '/groups/{id}/teamcontacts',
                            model: Models::TeamContactIndex)
      register.add_endpoint(id: :group_participations_index, type: :index, url: '/groups/{id}/participations',
                            model: Models::ParticipationIndex)

      # register.add_endpoint(id: :participation_index, type: :index, url: '/participations', model: Models::ParticipationIndex)
      register.add_endpoint(id: :participation_resource, type: :resource, url: '/participations/{id}',
                            model: Models::Participation)
      register.add_endpoint(id: :participation_participants_index, type: :index, url: '/participations/{id}/participants',
                            model: Models::ParticipantIndex)

      register.add_endpoint(id: :serie_index, type: :index, url: '/specification-series', model: Models::SerieIndex)
      register.add_endpoint(id: :serie_resource, type: :resource, url: '/specification-series/{shortname}',
                            model: Models::Serie)

      register.add_endpoint(id: :serie_specification_resource, type: :index,
                            url: '/specification-series/{shortname}/specifications', model: Models::SpecificationIndex)

      register.add_endpoint(id: :specification_index, type: :index, url: '/specifications',
                            model: Models::SpecificationIndex)
      register.add_endpoint(id: :specification_resource, type: :resource, url: '/specifications/{shortname}',
                            model: Models::Specification)
      register.add_endpoint(id: :specification_resource_version_index, type: :index, url: '/specifications/{shortname}/versions',
                            model: Models::SpecVersionIndex)

      register.add_endpoint(
        id: :specification_resource_version_resource,
        type: :resource,
        url: '/specifications/{shortname}/versions/{version}',
        model: Models::SpecVersion
      )
      register.add_endpoint(
        id: :specification_version_predecessors_index,
        type: :index,
        url: '/specifications/{shortname}/versions/{version}/predecessors',
        model: Models::SpecVersionIndex
      )
      register.add_endpoint(
        id: :specification_version_successors_index,
        type: :index,
        url: '/specifications/{shortname}/versions/{version}/successors',
        model: Models::SpecVersionIndex
      )
      register.add_endpoint(
        id: :specification_by_status_index,
        type: :index,
        url: '/specifications-by-status/{status}',
        model: Models::SpecificationIndex
      )
      register.add_endpoint(
        id: :specification_supersedes_index,
        type: :index,
        url: '/specifications/{shortname}/supersedes',
        model: Models::SpecificationIndex
      )
      register.add_endpoint(
        id: :specification_superseded_by_index,
        type: :index,
        url: '/specifications/{shortname}/superseded',
        model: Models::SpecificationIndex
      )
      register.add_endpoint(
        id: :specification_version_editors_index,
        type: :index,
        url: '/specifications/{shortname}/version/{version}/editors',
        model: Models::UserIndex
      )
      register.add_endpoint(
        id: :specification_version_deliverers_index,
        type: :index,
        url: '/specifications/{shortname}/version/{version}/deliverers',
        model: Models::UserIndex
      )

      # TODO: Why is this endpoint needed? There already is /specifications/{shortname}...
      # register.add_endpoint(
      #   id: :specification_by_shortname_index,
      #   type: :index,
      #   url: '/specifications-by-shortname/{shortname}',
      #   model: Models::SpecificationIndex
      # )

      register.add_endpoint(id: :translation_index, type: :index, url: '/translations', model: Models::TranslationIndex)
      register.add_endpoint(id: :translation_resource, type: :resource, url: '/translations/{id}',
                            model: Models::Translation)

      # NOTE: This endpoint doesn't exist, just here for reference.
      # register.add_endpoint(id: :user_index, type: :index, url: '/users', model: Models::UserIndex)

      register.add_endpoint(id: :user_groups_index, type: :index, url: '/users/{hash}/groups',
                            model: Models::GroupIndex)

      register.add_endpoint(id: :user_resource, type: :resource, url: '/users/{hash}', model: Models::User)

      register.add_endpoint(id: :user_affiliations_index, type: :index, url: '/users/{hash}/affiliations',
                            model: Models::AffiliationIndex)

      register.add_endpoint(id: :user_participations_index, type: :index, url: '/users/{hash}/participations',
                            model: Models::ParticipationIndex)

      register.add_endpoint(id: :user_chair_of_groups_index, type: :index, url: '/users/{hash}/chair-of-groups',
                            model: Models::GroupIndex)

      register.add_endpoint(id: :user_team_contact_of_groups_index, type: :index, url: '/users/{hash}/team-contact-of-groups',
                            model: Models::GroupIndex)

      register.add_endpoint(id: :user_specifications_index, type: :index, url: '/users/{hash}/specifications',
                            model: Models::SpecificationIndex)
    end
  end
end
