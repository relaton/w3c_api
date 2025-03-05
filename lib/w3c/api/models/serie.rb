# frozen_string_literal: true

require_relative 'base'
require_relative 'link'

# {
#     "shortname": "css-backgrounds",
#     "name": "CSS Backgrounds and Borders Module",
#     "_links": {
#         "self": {
#             "href": "https://api.w3.org/specification-series/css-backgrounds"
#         },
#         "specifications": {
#             "href": "https://api.w3.org/specification-series/css-backgrounds/specifications"
#         },
#         "current-specification": {
#             "href": "https://api.w3.org/specifications/css-backgrounds-3"
#         }
#     }
# }
#
# {
#   "shortname": "2dcontext",
#   "name": "HTML Canvas 2D Context",
#   "_links": {
#     "self": {
#       "href": "https://api.w3.org/specification-series/2dcontext"
#     },
#     "specifications": {
#       "href": "https://api.w3.org/specification-series/2dcontext/specifications"
#     },
#     "current-specification": {
#       "href": "https://api.w3.org/specifications/2dcontext"
#     }
#   }
# }

module W3c
  module Api
    module Models
      class SerieLinks < Lutaml::Model::Serializable
        attribute :self, Link
        attribute :specifications, Link
        attribute :current_specification, Link
      end

      class Serie < Base
        attribute :shortname, :string
        attribute :name, :string
        attribute :href, :string
        attribute :title, :string
        attribute :_links, SerieLinks

        # Get specifications in this series
        def specifications(client = nil)
          return nil unless client && _links&.specifications

          client.series_specifications(shortname)
        end

        # Get current specification in this series
        def current_specification(client = nil)
          return nil unless client && _links&.current_specification

          href = _links.current_specification.href
          shortname = href.split('/').last
          client.specification(shortname)
        end

        def self.from_response(response)
          transformed_response = transform_keys(response)

          series = new
          transformed_response.each do |key, value|
            case key
            when :_links
              links = value.each_with_object({}) do |(link_name, link_data), acc|
                acc[link_name] = Link.new(href: link_data[:href], title: link_data[:title])
              end
              series._links = SerieLinks.new(links)
            else
              series.send("#{key}=", value) if series.respond_to?("#{key}=")
            end
          end
          series
        end
      end
    end
  end
end
