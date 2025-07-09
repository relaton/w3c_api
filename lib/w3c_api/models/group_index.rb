# frozen_string_literal: true

require_relative "group"

module W3cApi
  module Models
    # Collection of groups
    class GroupIndex < Lutaml::Hal::Page
      hal_link :groups, key: "groups", realize_class: "Group", collection: true
    end
  end
end
