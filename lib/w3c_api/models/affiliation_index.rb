# frozen_string_literal: true

require_relative "affiliation"

module W3cApi
  module Models
    # Represents a collection of W3C affiliations.
    class AffiliationIndex < Lutaml::Hal::Page
      hal_link :affiliations, key: "affiliations",
                              realize_class: "Affiliation", collection: true
    end
  end
end
