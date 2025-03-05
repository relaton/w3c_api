# frozen_string_literal: true

require 'lutaml/model'
require_relative 'spec_version'
require_relative 'delegate_enumerable'

module W3c
  module Api
    module Models
      class SpecVersions < Lutaml::Model::Serializable
        extend DelegateEnumerable

        attribute :spec_versions, SpecVersion, collection: true

        delegate_enumerable :spec_versions
      end
    end
  end
end
