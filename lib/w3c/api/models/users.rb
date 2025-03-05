# frozen_string_literal: true

require 'lutaml/model'
require_relative 'user'
require_relative 'delegate_enumerable'

module W3c
  module Api
    module Models
      class Users < Lutaml::Model::Serializable
        extend DelegateEnumerable

        attribute :users, User, collection: true

        delegate_enumerable :users
      end
    end
  end
end
