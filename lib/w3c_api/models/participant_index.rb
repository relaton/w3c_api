# frozen_string_literal: true

require_relative "user"

module W3cApi
  module Models
    class ParticipantIndex < Lutaml::Hal::Page
      hal_link :participants, key: "participants", realize_class: "User",
                              collection: true
    end
  end
end
