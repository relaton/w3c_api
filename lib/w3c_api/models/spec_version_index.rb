# frozen_string_literal: true

require_relative "spec_version"

module W3cApi
  module Models
    class SpecVersionIndex < Lutaml::Hal::Page
      hal_link :spec_versions, key: "version-history",
                               realize_class: "SpecVersion", collection: true
    end
  end
end
