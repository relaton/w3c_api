# frozen_string_literal: true

require 'json'
require 'rainbow'
require 'pp'
require_relative 'hal'

module W3cApi
  class Client
    def specifications(options = {})
      Hal.instance.register.fetch(:specification_index, **options)
    end

    def specification(shortname, options = {})
      Hal.instance.register.fetch(:specification_resource, shortname: shortname, **options)
    end

    def specification_versions(shortname, options = {})
      Hal.instance.register.fetch(:specification_resource_version_index, shortname: shortname, **options)
    end

    def specification_version(shortname, version, options = {})
      Hal.instance.register.fetch(:specification_resource_version_resource, shortname: shortname, version: version,
                                                                            **options)
    end

    def specifications_by_status(status, options = {})
      Hal.instance.register.fetch(:specification_by_status_index, status: status, **options)
    end

    def specification_supersedes(shortname, options = {})
      Hal.instance.register.fetch(:specification_supersedes_index, shortname: shortname, **options)
    end

    def specification_superseded_by(shortname, options = {})
      Hal.instance.register.fetch(:specification_superseded_by_index, shortname: shortname, **options)
    end

    # New methods for editors and deliverers

    def specification_editors(shortname, options = {})
      Hal.instance.register.fetch(:specification_editors_index, shortname: shortname, **options)
    end

    def specification_deliverers(shortname, options = {})
      Hal.instance.register.fetch(:specification_deliverers_index, shortname: shortname, **options)
    end

    # Series methods

    def series(options = {})
      Hal.instance.register.fetch(:serie_index, **options)
    end

    def series_by_shortname(shortname, options = {})
      Hal.instance.register.fetch(:serie_resource, shortname: shortname, **options)
    end

    def series_specifications(shortname, options = {})
      Hal.instance.register.fetch(:serie_specification_resource, shortname: shortname, **options)
    end

    # Group methods

    def groups(options = {})
      Hal.instance.register.fetch(:group_index, **options)
    end

    def group(id, options = {})
      Hal.instance.register.fetch(:group_resource, id: id, **options)
    end

    def group_specifications(id, options = {})
      Hal.instance.register.fetch(:group_specifications_index, id: id, **options)
    end

    def group_users(id, options = {})
      Hal.instance.register.fetch(:group_users_index, id: id, **options)
    end

    def group_charters(id, options = {})
      Hal.instance.register.fetch(:group_charters_index, id: id, **options)
    end

    def group_chairs(id, options = {})
      Hal.instance.register.fetch(:group_chairs_index, id: id, **options)
    end

    def group_team_contacts(id, options = {})
      Hal.instance.register.fetch(:group_team_contacts_index, id: id, **options)
    end

    def group_participations(id, options = {})
      Hal.instance.register.fetch(:group_participations_index, id: id, **options)
    end

    # User methods

    # def users(options = {})
    #   raise ArgumentError,
    #         'The W3C API does not support fetching all users. You must provide a specific user ID with the user method.'
    # end

    def user(hash, options = {})
      Hal.instance.register.fetch(:user_resource, hash: hash, **options)
    end

    def user_groups(hash, options = {})
      Hal.instance.register.fetch(:user_groups_index, hash: hash, **options)
    end

    def user_affiliations(hash, options = {})
      Hal.instance.register.fetch(:user_affiliations_index, hash: hash, **options)
    end

    def user_participations(hash, options = {})
      Hal.instance.register.fetch(:user_participations_index, hash: hash, **options)
    end

    def user_chair_of_groups(hash, options = {})
      Hal.instance.register.fetch(:user_chair_of_groups_index, hash: hash, **options)
    end

    def user_team_contact_of_groups(hash, options = {})
      Hal.instance.register.fetch(:user_team_contact_of_groups_index, hash: hash, **options)
    end

    def user_specifications(hash, options = {})
      Hal.instance.register.fetch(:user_specifications_index, hash: hash, **options)
    end

    # Translation methods

    def translations(options = {})
      Hal.instance.register.fetch(:translation_index, **options)
    end

    def translation(id, options = {})
      Hal.instance.register.fetch(:translation_resource, id: id, **options)
    end

    # Affiliation methods

    def affiliations(options = {})
      Hal.instance.register.fetch(:affiliation_index, **options)
    end

    def affiliation(id, options = {})
      Hal.instance.register.fetch(:affiliation_resource, id: id, **options)
    end

    def affiliation_participants(id, options = {})
      Hal.instance.register.fetch(:affiliation_participants_index, id: id, **options)
    end

    def affiliation_participations(id, options = {})
      Hal.instance.register.fetch(:affiliation_participations_index, id: id, **options)
    end

    # Ecosystem methods

    def ecosystems(options = {})
      Hal.instance.register.fetch(:ecosystem_index, **options)
    end

    def ecosystem(id, options = {})
      Hal.instance.register.fetch(:ecosystem_resource, id: id, **options)
    end

    def ecosystem_groups(shortname, options = {})
      Hal.instance.register.fetch(:ecosystem_groups_index, shortname: shortname, **options)
    end

    def ecosystem_evangelists(shortname, options = {})
      Hal.instance.register.fetch(:ecosystem_evangelists_index, shortname: shortname, **options)
    end

    def ecosystem_member_organizations(shortname, options = {})
      Hal.instance.register.fetch(:ecosystem_member_organizations_index, shortname: shortname, **options)
    end

    # Participation methods

    def participation(id, options = {})
      Hal.instance.register.fetch(:participation_resource, id: id, **options)
    end

    def participation_participants(id, options = {})
      Hal.instance.register.fetch(:participation_participants_index, id: id, **options)
    end
  end
end
