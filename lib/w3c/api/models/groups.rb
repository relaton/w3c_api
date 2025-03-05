# frozen_string_literal: true

require 'lutaml/model'
require_relative 'group'
require_relative 'delegate_enumerable'

module W3c
  module Api
    module Models
      class Groups < Lutaml::Model::Serializable
        extend DelegateEnumerable

        attribute :groups, Group, collection: true

        delegate_enumerable :groups
      end
    end
  end
end
