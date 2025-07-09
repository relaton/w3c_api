# frozen_string_literal: true

require "json"
require "rainbow"
require "pp"
require_relative "hal"

module W3cApi
  class Client
    # Class method to list endpoints that support embed parameter
    def self.embed_supported_endpoints
      hal_instance = W3cApi::Hal.instance
      endpoints_with_embed = []

      hal_instance.register.models.each do |endpoint_id, endpoint_config|
        # Check if this endpoint has embed parameter support
        has_embed = endpoint_config[:parameters].any? do |param|
          param.name == "embed" && param.location == :query
        end

        endpoints_with_embed << endpoint_id if has_embed
      end

      endpoints_with_embed.sort
    end

    # Instance method to check if a specific endpoint supports embed
    def embed_supported?(endpoint_id)
      self.class.embed_supported_endpoints.include?(endpoint_id)
    end

    # Specification methods
    def specifications(options = {})
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

    %w[supersedes superseded_by editors deliverers].each do |method_suffix|
      define_method("specification_#{method_suffix}") do |shortname, options = {}|
        fetch_resource(:"specification_#{method_suffix}_index",
                       shortname: shortname, **options)
      end
    end

    def specification_version_editors(shortname, version, options = {})
      fetch_resource(:specification_version_editors_index,
                     shortname: shortname, version: version, **options)
    end

    def specification_version_deliverers(shortname, version, options = {})
      fetch_resource(:specification_version_deliverers_index,
                     shortname: shortname, version: version, **options)
    end

    # Series methods
    def series(options = {})
      fetch_resource(:serie_index, **options)
    end

    def series_by_shortname(shortname, options = {})
      fetch_resource(:serie_resource, shortname: shortname, **options)
    end

    def series_specifications(shortname, options = {})
      fetch_resource(:serie_specification_resource,
                     shortname: shortname, **options)
    end

    def series_current_specification(shortname, options = {})
      fetch_resource(:serie_current_specification_resource,
                     shortname: shortname, **options)
    end

    # Group methods
    def groups(options = {})
      fetch_resource(:group_index, **options)
    end

    def group(id, options = {})
      fetch_resource(:group_resource, id: id, **options)
    end

    %w[specifications users charters chairs team_contacts
       participations].each do |resource|
      define_method("group_#{resource}") do |id, options = {}|
        fetch_resource(:"group_#{resource}_index", id: id, **options)
      end
    end

    # User methods
    def user(hash, options = {})
      fetch_resource(:user_resource, hash: hash, **options)
    end

    %w[groups affiliations participations chair_of_groups
       team_contact_of_groups specifications].each do |resource|
      define_method("user_#{resource}") do |hash, options = {}|
        fetch_resource(:"user_#{resource}_index", hash: hash, **options)
      end
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

    %w[participants participations].each do |resource|
      define_method("affiliation_#{resource}") do |id, options = {}|
        fetch_resource(:"affiliation_#{resource}_index", id: id, **options)
      end
    end

    # Ecosystem methods
    def ecosystems(options = {})
      fetch_resource(:ecosystem_index, **options)
    end

    def ecosystem(shortname, options = {})
      fetch_resource(:ecosystem_resource, shortname: shortname, **options)
    end

    %w[groups evangelists member_organizations].each do |resource|
      define_method("ecosystem_#{resource}") do |shortname, options = {}|
        fetch_resource(:"ecosystem_#{resource}_index",
                       shortname: shortname, **options)
      end
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
