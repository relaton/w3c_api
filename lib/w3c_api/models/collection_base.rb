# frozen_string_literal: true

require 'lutaml/model'
require 'json'
require 'yaml'

module W3cApi
  module Models
    class CollectionBase < Lutaml::Model::Serializable
      # Common methods for all W3C API model collections
      extend DelegateEnumerable

      def self.collection_instance_class(klass, attribute)
        @collection_instance_class ||= klass
        @collection_attribute = attribute
      end

      # Create a model instance from a hash response
      def self.from_response(data)
        return new({ @collection_attribute => [] }) if data.nil?

        # Handle the case where data is expected to have 'items' key
        if data.is_a?(Hash)
          return new({ @collection_attribute => [] }) unless data.key?(:items) || data.key?('items')

          items_key = data.key?(:items) ? :items : 'items'
          items = data[items_key] || []

          # Set pagination metadata
          result = new
          data.each do |key, value|
            next if key == items_key

            result.send("#{key}=", value) if result.respond_to?("#{key}=")
          end

          # Process items array
          transformed_items = items.map do |item|
            @collection_instance_class.new(transform_keys(item))
          end

          result.send("#{@collection_attribute}=", transformed_items)
          return result

          # Handle case where response is a hash but doesn't contain 'items'

        end

        # Handle case where data is directly the items array
        if data.is_a?(Array)
          transformed_data = data.map do |item|
            @collection_instance_class.new(transform_keys(item))
          end
          return new({ @collection_attribute => transformed_data })
        end

        # For backward compatibility, try to create a model instance anyway
        new({ @collection_attribute => [] })
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
