# frozen_string_literal: true

require_relative "participation"

module W3cApi
  module Models
    class ParticipationIndex < Lutaml::Hal::Page
      hal_link :participations, key: "participations",
                                realize_class: "Participation", collection: true
    end
  end
end
