# frozen_string_literal: true

require_relative 'base'
require_relative 'link'
require_relative 'spec_version_ref'

# {
#     "uri": "https://www.w3.org/WAI/videos/standards-and-benefits/"
#     "title": "Video Introduction to Web Accessibility and W3C Standards"
#     "_links": {
#         "self": {
#             "href": "https://api.w3.org/callsfortranslation/5"
#         }
#         "translations": {
#             "href": "https://api.w3.org/callsfortranslation/5/translations"
#         }
#     }
# }

module W3c
  module Api
    module Models
      class CallForTranslationLinks < Lutaml::Model::Serializable
        attribute :self, Link
        attribute :translations, Link
      end

      class CallForTranslation < Base
        attribute :uri, :string
        attribute :title, :string
        attribute :spec_version, SpecVersionRef
        attribute :_links, CallForTranslationLinks

        # Get translations for this call for translation
        def translations(client = nil)
          return nil unless client && _links&.translations

          client.call_for_translation_translations(uri)
        end

        def self.from_response(response)
          transformed_response = transform_keys(response)

          cft = new
          transformed_response.each do |key, value|
            case key
            when :_links
              links = value.each_with_object({}) do |(link_name, link_data), acc|
                acc[link_name] = Link.new(href: link_data[:href], title: link_data[:title])
              end
              cft._links = CallForTranslationLinks.new(links)
            else
              cft.send("#{key}=", value) if cft.respond_to?("#{key}=")
            end
          end
          cft
        end
      end
    end
  end
end
