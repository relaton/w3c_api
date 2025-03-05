# frozen_string_literal: true

require 'lutaml/model'
require_relative 'service'
require_relative 'delegate_enumerable'

module W3c
  module Api
    module Models
      class Services < Lutaml::Model::Serializable
        extend DelegateEnumerable

        attribute :services, Service, collection: true

        delegate_enumerable :services
      end
    end
  end
end
