# frozen_string_literal: true

require_relative 'base'
require_relative 'link'

# {
#   "shortlink"=>"https://www.w3.org/TR/PNG/",
#   "description"=>"<p>This document describes PNG (Portable Network Graphics), an extensible file format for the lossless, portable, well-compressed storage of raster images. PNG provides a patent-free replacement for GIF and can also replace many common uses of TIFF. Indexed-color, grayscale, and truecolor images are supported, plus an optional alpha channel. Sample depths range from 1 to 16 bits.</p>\r\n<p>PNG is designed to work well in online viewing applications, such as the World Wide Web, so it is fully streamable with a progressive display option. PNG is robust, providing both full file integrity checking and simple detection of common transmission errors. Also, PNG can store gamma and chromaticity data for improved color matching on heterogeneous platforms.</p>\r\n<p>This specification defines an Internet Media Type image/png.</p>",
#   "title"=>"Portable Network Graphics (PNG) Specification (Second Edition)",
#   "shortname"=>"png-2",
#   "editor-draft"=>"https://w3c.github.io/png/",
#   "_links"=>{
#     "self"=>{
#       "href"=>"https://api.w3.org/specifications/png-2"
#     },
#     "version-history"=>{
#       "href"=>"https://api.w3.org/specifications/png-2/versions"
#     },
#     "first-version"=>{
#       "href"=>"https://api.w3.org/specifications/png-2/versions/20030520",
#       "title"=>"Proposed Recommendation"
#     },
#     "latest-version"=>{
#       "href"=>"https://api.w3.org/specifications/png-2/versions/20031110",
#       "title"=>"Recommendation"
#     },
#     "series"=>{
#       "href"=>"https://api.w3.org/specification-series/png"
#     }
#   }
# }

module W3cApi
    module Models
      class SpecificationLinks < Lutaml::Model::Serializable
        attribute :self, Link
        attribute :version_history, Link
        attribute :first_version, Link
        attribute :latest_version, Link
        attribute :series, Link
      end

      class Specification < Base
        attribute :shortlink, :string
        attribute :description, :string
        attribute :title, :string
        attribute :href, :string
        attribute :shortname, :string
        attribute :editor_draft, :string
        attribute :series_version, :string
        attribute :_links, SpecificationLinks

        # Return versions of this specification
        def versions(client = nil)
          return nil unless client && shortname

          client.specification_versions(shortname)
        end

        def self.from_response(response)
          transformed_response = transform_keys(response)

          spec = new
          transformed_response.each do |key, value|
            case key
            when :_links
              links = value.each_with_object({}) do |(link_name, link_data), acc|
                acc[link_name] = Link.new(href: link_data[:href], title: link_data[:title])
              end
              spec._links = SpecificationLinks.new(links)
            else
              spec.send("#{key}=", value) if spec.respond_to?("#{key}=")
            end
          end
          spec
        end
      end
    end
end
