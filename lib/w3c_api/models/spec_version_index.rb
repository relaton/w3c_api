# frozen_string_literal: true

require_relative 'spec_version'

module W3cApi
  module Models
    class SpecVersionIndex < Lutaml::Hal::Page
      hal_link :versions, key: 'versions', realize_class: 'SpecVersion', collection: true
      hal_link :spec_versions, key: 'version-history', realize_class: 'SpecVersion', collection: true
      hal_link :predecessor_version, key: 'predecessor-version', realize_class: 'SpecVersion', collection: true
      hal_link :successor_version, key: 'successor-version', realize_class: 'SpecVersion', collection: true
    end
  end
end
