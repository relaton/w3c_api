# frozen_string_literal: true

require 'lutaml/model'
require 'json'
require 'yaml'

module W3c
  module Api
    module Models
      class CollectionBase < Lutaml::Model::Serializable
        # Common methods for all W3C API model collections
        extend DelegateEnumerable

        attr_accessor :collection_instance_class

        def self.collection_instance_class(klass, attribute)
          @collection_instance_class ||= klass
          @collection_attribute = attribute
        end

        # Create a model instance from an array of hashes
        def self.from_response(data)
          # Convert keys with hyphens to snake_case for Ruby
          transformed_data = if data.nil?
                               []
                             else
                               data.map do |item|
                                 # Create a model instance from hash
                                 @collection_instance_class.new(transform_keys(item))
                               end
                             end

          # Create collection model instance
          new({ @collection_attribute => transformed_data })
        end

        # Utility function to transform kebab-case to snake_case
        def self.transform_keys(data)
          case data
          when Hash
            result = {}
            data.each do |key, value|
              snake_key = key.to_s.tr('-', '_').to_sym
              result[snake_key] = transform_keys(value)
            end
            result
          when Array
            data.map { |item| transform_keys(item) }
          else
            data
          end
        end
      end
    end
  end
end
