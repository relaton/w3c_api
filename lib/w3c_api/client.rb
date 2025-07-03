# frozen_string_literal: true

require "json"
require "rainbow"
require "pp"
require_relative "hal"

module W3cApi
  class Client
    def specifications(options = nil)
      fetch_resource(:specification_index, **(options || {}))
    end

    def specification(shortname, options = {})
      fetch_resource(:specification_resource, shortname: shortname, **options)
    end

    def specification_versions(shortname, options = {})
      fetch_resource(:specification_resource_version_index,
                     shortname: shortname, **options)
    end

    def specification_version(shortname, version, options = {})
      fetch_resource(
        :specification_resource_version_resource,
        shortname: shortname,
        version: version,
        **options,
      )
    end

    def specifications_by_status(status, options = {})
      fetch_resource(:specification_by_status_index, status: status, **options)
    end

    def specification_supersedes(shortname, options = {})
      fetch_resource(:specification_supersedes_index, shortname: shortname,
                                                      **options)
    end

    def specification_superseded_by(shortname, options = {})
      fetch_resource(:specification_superseded_by_index, shortname: shortname,
                                                         **options)
    end

    # New methods for editors and deliverers

    def specification_editors(shortname, options = {})
      fetch_resource(:specification_editors_index, shortname: shortname,
                                                   **options)
    end

    def specification_deliverers(shortname, options = {})
      fetch_resource(:specification_deliverers_index, shortname: shortname,
                                                      **options)
    end

    # Series methods

    def series(options = {})
      fetch_resource(:serie_index, **options)
    end

    def series_by_shortname(shortname, options = {})
      fetch_resource(:serie_resource, shortname: shortname, **options)
    end

    def series_specifications(shortname, options = {})
      fetch_resource(:serie_specification_resource, shortname: shortname,
                                                    **options)
    end

    # Group methods

    def groups(options = {})
      fetch_resource(:group_index, **options)
    end

    def group(id, options = {})
      fetch_resource(:group_resource, id: id, **options)
    end

    def group_specifications(id, options = {})
      fetch_resource(:group_specifications_index, id: id, **options)
    end

    def group_users(id, options = {})
      fetch_resource(:group_users_index, id: id, **options)
    end

    def group_charters(id, options = {})
      fetch_resource(:group_charters_index, id: id, **options)
    end

    def group_chairs(id, options = {})
      fetch_resource(:group_chairs_index, id: id, **options)
    end

    def group_team_contacts(id, options = {})
      fetch_resource(:group_team_contacts_index, id: id, **options)
    end

    def group_participations(id, options = {})
      fetch_resource(:group_participations_index, id: id, **options)
    end

    # User methods

    # def users(options = {})
    #   raise ArgumentError,
    #     'The W3C API does not support fetching all users. ' \
    #     'You must provide a specific user ID with the user method.'
    # end

    def user(hash, options = {})
      fetch_resource(:user_resource, hash: hash, **options)
    end

    def user_groups(hash, options = {})
      fetch_resource(:user_groups_index, hash: hash, **options)
    end

    def user_affiliations(hash, options = {})
      fetch_resource(:user_affiliations_index, hash: hash, **options)
    end

    def user_participations(hash, options = {})
      fetch_resource(:user_participations_index, hash: hash, **options)
    end

    def user_chair_of_groups(hash, options = {})
      fetch_resource(:user_chair_of_groups_index, hash: hash, **options)
    end

    def user_team_contact_of_groups(hash, options = {})
      fetch_resource(:user_team_contact_of_groups_index, hash: hash, **options)
    end

    def user_specifications(hash, options = {})
      fetch_resource(:user_specifications_index, hash: hash, **options)
    end

    # Translation methods

    def translations(options = {})
      fetch_resource(:translation_index, **options)
    end

    def translation(id, options = {})
      fetch_resource(:translation_resource, id: id, **options)
    end

    # Affiliation methods

    def affiliations(options = {})
      fetch_resource(:affiliation_index, **options)
    end

    def affiliation(id, options = {})
      fetch_resource(:affiliation_resource, id: id, **options)
    end

    def affiliation_participants(id, options = {})
      fetch_resource(:affiliation_participants_index, id: id, **options)
    end

    def affiliation_participations(id, options = {})
      fetch_resource(:affiliation_participations_index, id: id, **options)
    end

    # Ecosystem methods

    def ecosystems(options = {})
      fetch_resource(:ecosystem_index, **options)
    end

    def ecosystem(id, options = {})
      fetch_resource(:ecosystem_resource, id: id, **options)
    end

    def ecosystem_groups(shortname, options = {})
      fetch_resource(:ecosystem_groups_index, shortname: shortname, **options)
    end

    def ecosystem_evangelists(shortname, options = {})
      fetch_resource(:ecosystem_evangelists_index, shortname: shortname,
                                                   **options)
    end

    def ecosystem_member_organizations(shortname, options = {})
      fetch_resource(:ecosystem_member_organizations_index,
                     shortname: shortname, **options)
    end

    # Participation methods

    def participation(id, options = {})
      fetch_resource(:participation_resource, id: id, **options)
    end

    def participation_participants(id, options = {})
      fetch_resource(:participation_participants_index, id: id, **options)
    end

    private

    def fetch_resource(resource_key, **params)
      if params.any?
        Hal.instance.register.fetch(resource_key, **params)
      else
        Hal.instance.register.fetch(resource_key)
      end
    end
  end
end
