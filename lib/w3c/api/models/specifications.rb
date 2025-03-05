# frozen_string_literal: true

require 'lutaml/model'
require_relative 'specification'
require_relative 'delegate_enumerable'
require_relative 'collection_base'

module W3c
  module Api
    module Models
      class Specifications < CollectionBase
        attribute :specifications, Specification, collection: true

        delegate_enumerable :specifications
        collection_instance_class Specification, :specifications
      end
    end
  end
end
