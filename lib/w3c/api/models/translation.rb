# frozen_string_literal: true

require_relative 'base'
require_relative 'call_for_translation_ref'
require_relative 'link'
require_relative 'user'

# {
#   "states"=>[
#     "review"
#   ],
#   "uri"=>"https://github.com/w3c/wai-video-standards-and-benefits/blob/master/index.fr.md",
#   "title"=>"Vidéo : introduction à l’accessibilité web et aux standards du W3C",
#   "language"=>"fr",
#   "translators"=>[
#     {
#       "id"=>40757,
#       "name"=>"Stéphane Deschamps",
#       "given"=>"Stéphane",
#       "family"=>"Deschamps",
#       "work-title"=>"Mr.",
#       "biography"=>"I love accessibility and standards. Don't we all.",
#       "country-code"=>"FR",
#       "city"=>"Arcueil Cedex",
#       "connected-accounts"=>[],   #<<<< TODO THIS IS NOT DONE
#       "discr"=>"user",
#       "_links"=>{
#         "self"=>{
#           "href"=>"https://api.w3.org/users/56nw1z8a5uo0sscsgk4kso8g0004008"
#         },
#         "affiliations"=>{
#           "href"=>"https://api.w3.org/users/56nw1z8a5uo0sscsgk4kso8g0004008/affiliations"
#         },
#         "groups"=>{
#           "href"=>"https://api.w3.org/users/56nw1z8a5uo0sscsgk4kso8g0004008/groups"
#         },
#         "specifications"=>{
#           "href"=>"https://api.w3.org/users/56nw1z8a5uo0sscsgk4kso8g0004008/specifications"
#         },
#         "photos"=>[
#           {
#             "href"=>"https://www.w3.org/thumbnails/360/avatar-images/56nw1z8a5uo0sscsgk4kso8g0004008.webp?x-version=1",
#             "name"=>"large"
#           },
#           {
#             "href"=>"https://www.w3.org/thumbnails/100/avatar-images/56nw1z8a5uo0sscsgk4kso8g0004008.webp?x-version=1",
#             "name"=>"thumbnail"
#           },
#           {
#             "href"=>"https://www.w3.org/thumbnails/48/avatar-images/56nw1z8a5uo0sscsgk4kso8g0004008.webp?x-version=1",
#             "name"=>"tiny"
#           }
#         ],
#         "participations"=>{
#           "href"=>"https://api.w3.org/users/56nw1z8a5uo0sscsgk4kso8g0004008/participations"
#         },
#         "chair_of_groups"=>{
#           "href"=>"https://api.w3.org/users/56nw1z8a5uo0sscsgk4kso8g0004008/chair-of-groups"
#         },
#         "team_contact_of_groups"=>{
#           "href"=>"https://api.w3.org/users/56nw1z8a5uo0sscsgk4kso8g0004008/team-contact-of-groups"
#         }
#       }
#     }
#   ],
#   "authorized"=>false,
#   "call-for-translation"=>{
#     "uri"=>"https://www.w3.org/WAI/videos/standards-and-benefits/",
#     "title"=>"Video Introduction to Web Accessibility and W3C Standards",
#     "_links"=>{
#       "self"=>{
#         "href"=>"https://api.w3.org/callsfortranslation/5"
#       },
#       "translations"=>{
#         "href"=>"https://api.w3.org/callsfortranslation/5/translations"
#       }
#     }
#   },
#   "comments"=>"Needs updating. Requested on 22 Feb 2019.",
#   "_links"=>{
#     "self"=>{
#       "href"=>"https://api.w3.org/translations/2"
#     }
#   }
# }

module W3c
  module Api
    module Models
      class TranslationLinks < Lutaml::Model::Serializable
        attribute :self, Link
      end

      class Translation < Base
        attribute :uri, :string
        attribute :title, :string
        attribute :href, :string
        attribute :language, :string
        attribute :published, :string # Date-time format
        attribute :updated, :string # Date-time format
        attribute :authorized, :boolean
        attribute :lto_name, :string
        attribute :call_for_translation, CallForTranslationRef
        attribute :comments, :string
        attribute :states, :string, collection: true
        attribute :translators, User, collection: true
        attribute :_links, TranslationLinks

        # Parse date strings to Date objects
        def published_date
          Date.parse(published) if published
        rescue Date::Error
          nil
        end

        def updated_date
          Date.parse(updated) if updated
        rescue Date::Error
          nil
        end

        # Get the call for translation as a CallForTranslation object
        def call_for_translation_object
          return nil unless call_for_translation

          Models::CallForTranslation.new(call_for_translation)
        end

        # Get the specification version associated with this translation
        def specification_version(client = nil)
          return nil unless call_for_translation&.spec_version

          call_for_translation.spec_version
        end

        def self.from_response(response)
          transformed_response = transform_keys(response)

          translation = new
          transformed_response.each do |key, value|
            case key
            when :_links
              links = value.each_with_object({}) do |(link_name, link_data), acc|
                acc[link_name] = Link.new(href: link_data[:href], title: link_data[:title])
              end
              translation._links = TranslationLinks.new(links)
            when :call_for_translation
              translation.call_for_translation = CallForTranslationRef.new(value)
            when :translators
              # Handle translators as User objects if present
              if value.is_a?(Array)
                users = value.map { |user_data| User.from_response(user_data) }
                translation.translators = users
              end
            else
              translation.send("#{key}=", value) if translation.respond_to?("#{key}=")
            end
          end
          translation
        end
      end
    end
  end
end
