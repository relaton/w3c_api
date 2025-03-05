# frozen_string_literal: true

require 'lutaml/model'
require_relative 'ecosystem'
require_relative 'delegate_enumerable'

module W3c
  module Api
    module Models
      class Ecosystems < Lutaml::Model::Serializable
        extend DelegateEnumerable

        attribute :ecosystems, Ecosystem, collection: true

        delegate_enumerable :ecosystems
      end
    end
  end
end
