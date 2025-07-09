# frozen_string_literal: true

require_relative "user"

module W3cApi
  module Models
    class TeamContactIndex < Lutaml::Hal::Page
      hal_link :team_contacts, key: "team-contacts", realize_class: "User",
                               collection: true
    end
  end
end
