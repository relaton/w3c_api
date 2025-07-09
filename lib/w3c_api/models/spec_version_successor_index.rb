# frozen_string_literal: true

require_relative "spec_version"

module W3cApi
  module Models
    class SpecVersionSuccessorIndex < Lutaml::Hal::Page
      hal_link :successor_versions, key: "successor-version",
                                    realize_class: "SpecVersion", collection: true
    end
  end
end
