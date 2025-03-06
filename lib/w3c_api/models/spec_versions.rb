# frozen_string_literal: true

require 'lutaml/model'
require_relative 'spec_version'
require_relative 'delegate_enumerable'
require_relative 'collection_base'

module W3cApi
    module Models
      class SpecVersions < CollectionBase
        attribute :spec_versions, SpecVersion, collection: true

        delegate_enumerable :spec_versions
        collection_instance_class SpecVersion, :spec_versions
      end
    end
end
