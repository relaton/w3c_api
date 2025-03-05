# frozen_string_literal: true

require 'lutaml/model'
require_relative 'series'
require_relative 'delegate_enumerable'
require_relative 'collection_base'

module W3c
  module Api
    module Models
      class SeriesCollection < CollectionBase
        attribute :series, Series, collection: true

        delegate_enumerable :series
        collection_instance_class Series, :series
      end
    end
  end
end
