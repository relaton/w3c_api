# frozen_string_literal: true

require 'lutaml/model'
require 'json'
require 'yaml'

module W3c
  module Api
    module Models
      class Base < Lutaml::Model::Serializable
        # Common methods for all W3C API models

        # Create a model instance from a JSON string or hash
        def self.from_response(data)
          data = JSON.parse(data) if data.is_a?(String)

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

        # Convert a model instance to a hash
        def to_hash
          result = {}
          # Use instance_variables to get all attributes
          instance_variables.each do |var|
            attr_name = var.to_s.delete('@')
            attr_value = send(attr_name) if respond_to?(attr_name)
            next if attr_value.nil?

            # Convert snake_case back to kebab-case for API
            api_key = attr_name.to_s.tr('_', '-')

            # Transform value if needed
            transformed_value = case attr_value
                                when Base
                                  attr_value.to_hash
                                when Array
                                  attr_value.map { |v| v.is_a?(Base) ? v.to_hash : v }
                                else
                                  attr_value
                                end

            result[api_key] = transformed_value
          end
          result
        end

        # JSON serialization
        def to_json(*_args)
          JSON.pretty_generate(to_hash)
        end

        # YAML serialization
        def to_yaml(*_args)
          YAML.dump(to_hash)
        end
      end
    end
  end
end
