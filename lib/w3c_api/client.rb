# frozen_string_literal: true

require 'json'
require 'rainbow'
require 'pp'
require_relative 'hal'

module W3cApi
  class Client
    def specifications(options = {})
      Hal.instance.register.fetch(:specification_index)
    end

    def specification(shortname, options = {})
      Hal.instance.register.fetch(:specification_resource, shortname: shortname)
    end

    def specification_versions(shortname, options = {})
      Hal.instance.register.fetch(:specification_resource_version_index, shortname: shortname)
    end

    def specification_version(shortname, version, options = {})
      Hal.instance.register.fetch(:specification_resource_version_resource, shortname: shortname, version: version)
    end

    def specifications_by_status(status, options = {})
      Hal.instance.register.fetch(:specification_by_status_index, status: status)
    end

    def specification_supersedes(shortname, options = {})
      Hal.instance.register.fetch(:specification_supersedes_index, shortname: shortname)
    end

    def specification_superseded_by(shortname, options = {})
      Hal.instance.register.fetch(:specification_superseded_by_index, shortname: shortname)
    end

    # New methods for editors and deliverers

    def specification_editors(shortname, options = {})
      Hal.instance.register.fetch(:specification_editors_index, shortname: shortname)
    end

    def specification_deliverers(shortname, options = {})
      Hal.instance.register.fetch(:specification_deliverers_index, shortname: shortname)
    end

    # Series methods

    def series(options = {})
      Hal.instance.register.fetch(:serie_index)
    end

    def series_by_shortname(shortname, options = {})
      Hal.instance.register.fetch(:serie_resource, shortname: shortname)
    end

    def series_specifications(shortname, options = {})
      Hal.instance.register.fetch(:serie_specification_resource, shortname: shortname)
    end

    # # Group methods

    def groups(options = {})
      Hal.instance.register.fetch(:group_index)
    end

    def group(id, options = {})
      Hal.instance.register.fetch(:group_resource, id: id)
    end

    def group_specifications(id, options = {})
      Hal.instance.register.fetch(:group_specifications_index, id: id)
    end

    def group_users(id, options = {})
      Hal.instance.register.fetch(:group_users_index, id: id)
    end

    def group_charters(id, options = {})
      Hal.instance.register.fetch(:group_charters_index, id: id)
    end

    # def group_chairs(id, options = {})
    #   response = get("groups/#{id}/chairs", options)
    #   page_class = Lutaml::Hal::Page.create_subclass_for(Models::Users)
    #   page_class.from_json(response.to_json)
    # rescue Lutaml::Hal::NotFoundError
    #   # Return empty users collection when endpoint not found
    #   Models::Users.from_response([])
    # end

    # def group_team_contacts(id, options = {})
    #   response = get("groups/#{id}/teamcontacts", options)
    #   page_class = Lutaml::Hal::Page.create_subclass_for(Models::Users)
    #   page_class.from_json(response.to_json)
    # rescue Lutaml::Hal::NotFoundError
    #   # Return empty users collection when endpoint not found
    #   Models::Users.from_response([])
    # end

    # def group_participations(id, options = {})
    #   response = get("groups/#{id}/participations", options)
    #   page_class = Lutaml::Hal::Page.create_subclass_for(Models::Participations)
    #   page_class.from_json(response.to_json)
    # end

    # # User methods

    # def users(options = {})
    #   raise ArgumentError,
    #         'The W3C API does not support fetching all users. You must provide a specific user ID with the user method.'
    # end

    def user(hash, options = {})
      Hal.instance.register.fetch(:user_resource, hash: hash)
    end

    def user_groups(hash, options = {})
      Hal.instance.register.fetch(:user_groups_index, hash: hash)
    end

    def user_affiliations(hash, options = {})
      Hal.instance.register.fetch(:user_affiliations_index, hash: hash)
    end

    def user_participations(hash, options = {})
      Hal.instance.register.fetch(:user_participations_index, hash: hash)
    end

    def user_chair_of_groups(hash, options = {})
      Hal.instance.register.fetch(:user_chair_of_groups_index, hash: hash)
    end

    def user_team_contact_of_groups(hash, options = {})
      Hal.instance.register.fetch(:user_team_contact_of_groups_index, hash: hash)
    end

    def user_specifications(hash, options = {})
      Hal.instance.register.fetch(:user_specifications_index, hash: hash)
    end

    # # Translation methods

    def translations(options = {})
      Hal.instance.register.fetch(:translation_index)
    end

    def translation(id, options = {})
      Hal.instance.register.fetch(:translation_resource, id: id)
    end

    # Affiliation methods

    def affiliations(options = {})
      Hal.instance.register.fetch(:affiliation_index)
    end

    def affiliation(id, options = {})
      Hal.instance.register.fetch(:affiliation_resource, id: id)
    end

    # def affiliation_participants(id, options = {})
    #   response = get("affiliations/#{id}/participants", options)
    #   page_class = Lutaml::Hal::Page.create_subclass_for(Models::Users)
    #   page_class.from_json(response.to_json)
    # end

    # def affiliation_participations(id, options = {})
    #   response = get("affiliations/#{id}/participations", options)
    #   page_class = Lutaml::Hal::Page.create_subclass_for(Models::Participations)
    #   page_class.from_json(response.to_json)
    # end

    # Ecosystem methods

    def ecosystems(options = {})
      Hal.instance.register.fetch(:ecosystem_index)
    end

    def ecosystem(id, options = {})
      Hal.instance.register.fetch(:ecosystem_resource, id: id)
    end

    # def ecosystem_groups(shortname, options = {})
    #   response = get("ecosystems/#{shortname}/groups", options)
    #   page_class = Lutaml::Hal::Page.create_subclass_for(Models::Groups)
    #   page_class.from_json(response.to_json)
    # end

    # def ecosystem_evangelists(shortname, options = {})
    #   response = get("ecosystems/#{shortname}/evangelists", options)
    #   page_class = Lutaml::Hal::Page.create_subclass_for(Models::Users)
    #   page_class.from_json(response.to_json)
    # end

    # def ecosystem_member_organizations(shortname, options = {})
    #   response = get("ecosystems/#{shortname}/member-organizations", options)
    #   page_class = Lutaml::Hal::Page.create_subclass_for(Models::Affiliations)
    #   page_class.from_json(response.to_json)
    # end

    # # Participation methods

    # def participation(id, options = {})
    #   response = get("participations/#{id}", options)
    #   Models::Participation.from_json(response.to_json)
    # end

    # def participation_participants(id, options = {})
    #   response = get("participations/#{id}/participants", options)
    #   page_class = Lutaml::Hal::Page.create_subclass_for(Models::Users)
    #   page_class.from_json(response.to_json)
    # end
  end
end
