# frozen_string_literal: true

module W3cApi
  # Module for discovering and working with embed-supported endpoints
  module Embed
    class << self
      # Get list of endpoints that support embed parameter
      def supported_endpoints
        W3cApi::Client.embed_supported_endpoints
      end

      # Check if a specific endpoint supports embed
      def supports_embed?(endpoint_id)
        supported_endpoints.include?(endpoint_id.to_sym)
      end

      # Get human-readable descriptions of embed-supported endpoints
      def endpoint_descriptions
        {
          specification_index: "Specifications index with embedded specification details",
          group_index: "Groups index with embedded group details",
          serie_index: "Series index with embedded series details",
        }
      end

      # Get comprehensive embed information
      def embed_info
        {
          supported_endpoints: supported_endpoints,
          descriptions: endpoint_descriptions,
          usage_example: {
            discovery: "W3cApi::Client.embed_supported_endpoints",
            usage: "W3cApi::Client.new.specifications(embed: true, items: 2)",
            automatic_realization: "spec_link.realize  # Uses embedded content automatically",
          },
        }
      end
    end
  end
end
