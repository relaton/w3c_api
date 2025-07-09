# frozen_string_literal: true

require_relative "spec_version"

module W3cApi
  module Models
    class SpecVersionPredecessorIndex < Lutaml::Hal::Page
      hal_link :predecessor_versions, key: "predecessor-version",
                                      realize_class: "SpecVersion", collection: true
    end
  end
end
