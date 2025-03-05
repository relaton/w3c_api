# frozen_string_literal: true

require 'lutaml/model'
require_relative 'specification'
require_relative 'delegate_enumerable'

module W3c
  module Api
    module Models
      class Specifications < Lutaml::Model::Serializable
        extend DelegateEnumerable

        attribute :specifications, Specification, collection: true

        delegate_enumerable :specifications
      end
    end
  end
end
