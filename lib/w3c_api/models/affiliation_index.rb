# frozen_string_literal: true

require_relative 'affiliation'

module W3cApi
  module Models
    class AffiliationIndex < Lutaml::Hal::Page
      hal_link :affiliations, key: 'affiliations', realize_class: 'Affiliation', collection: true
    end
  end
end
