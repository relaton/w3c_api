# frozen_string_literal: true

require_relative "call_for_translation"
require_relative "user"

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

module W3cApi
  module Models
    class Translation < Lutaml::Hal::Resource
      attribute :uri, :string
      attribute :title, :string
      attribute :href, :string
      attribute :language, :string
      attribute :published, :date_time
      attribute :updated, :date_time
      attribute :authorized, :boolean
      attribute :lto_name, :string
      attribute :call_for_translation, CallForTranslation
      attribute :comments, :string
      attribute :states, :string, collection: true
      attribute :translators, User, collection: true

      hal_link :self, key: "self", realize_class: "Translation"

      key_value do
        %i[
          uri
          title
          href
          language
          published
          updated
          authorized
          lto_name
          call_for_translation
          comments
          states
          translators
        ].each do |key|
          map key.to_s.tr("_", "-"), to: key
        end
      end
    end
  end
end
