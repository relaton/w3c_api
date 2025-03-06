# frozen_string_literal: true

require 'lutaml/model'
require 'json'
require 'yaml'

module W3cApi
  module Models
    class Base < Lutaml::Model::Serializable
      # Common methods for all W3C API models

      # Create a model instance from a JSON hash
      def self.from_response(data)
        # Convert keys with hyphens to snake_case for Ruby
        transformed_data = transform_keys(data)

        # Create model instance
        new(transformed_data)
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
