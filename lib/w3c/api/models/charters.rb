# frozen_string_literal: true

require 'lutaml/model'
require_relative 'charter'
require_relative 'delegate_enumerable'
require_relative 'collection_base'

module W3c
  module Api
    module Models
      class Charters < CollectionBase
        attribute :charters, Charter, collection: true

        delegate_enumerable :charters
        collection_instance_class Charter, :charters
      end
    end
  end
end
