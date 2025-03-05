# frozen_string_literal: true

require 'lutaml/model'
require_relative 'participation'
require_relative 'delegate_enumerable'
require_relative 'collection_base'

module W3c
  module Api
    module Models
      class Participations < CollectionBase
        attribute :participations, Participation, collection: true

        delegate_enumerable :participations
        collection_instance_class Participation, :participations
      end
    end
  end
end
