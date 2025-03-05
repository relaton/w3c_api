# frozen_string_literal: true

require 'lutaml/model'
require_relative 'charter'
require_relative 'delegate_enumerable'

module W3c
  module Api
    module Models
      class Charters < Lutaml::Model::Serializable
        extend DelegateEnumerable

        attribute :charters, Charter, collection: true

        delegate_enumerable :charters
      end
    end
  end
end
