# frozen_string_literal: true

# https://api.w3.org/users/f1of1ovb5rydm8s0go04oco0cgk0sow44w
# {
#     "id": 128112,
#     "name": "Jennifer Strickland",
#     "given": "Jennifer",
#     "family": "Strickland",
#     "country-code": "US",
#     "connected-accounts": [
#         {
#             "created": "2021-03-12T22:06:06+00:00",
#             "service": "github",
#             "identifier": "57469",
#             "nickname": "jenstrickland",
#             "profile-picture": "https://avatars.githubusercontent.com/u/57469?v=4",
#             "href": "https://github.com/jenstrickland",
#             "_links": {
#                 "user": {
#                     "href": "https://api.w3.org/users/f1ovb5rydm8s0go04oco0cgk0sow44w"
#                 }
#             }
#         }
#     ],
#     "discr": "user",
#     "_links": {
#         "self": {
#             "href": "https://api.w3.org/users/f1ovb5rydm8s0go04oco0cgk0sow44w"
#         },
#         "affiliations": {
#             "href": "https://api.w3.org/users/f1ovb5rydm8s0go04oco0cgk0sow44w/affiliations"
#         },
#         "groups": {
#             "href": "https://api.w3.org/users/f1ovb5rydm8s0go04oco0cgk0sow44w/groups"
#         },
#         "specifications": {
#             "href": "https://api.w3.org/users/f1ovb5rydm8s0go04oco0cgk0sow44w/specifications"
#         },
#         "photos": [
#             {
#                 "href": "https://www.w3.org/thumbnails/360/avatar-images/f1ovb5rydm8s0go04oco0cgk0sow44w.webp?x-version=3",
#                 "name": "large"
#             },
#             {
#                 "href": "https://www.w3.org/thumbnails/100/avatar-images/f1ovb5rydm8s0go04oco0cgk0sow44w.webp?x-version=3",
#                 "name": "thumbnail"
#             },
#             {
#                 "href": "https://www.w3.org/thumbnails/48/avatar-images/f1ovb5rydm8s0go04oco0cgk0sow44w.webp?x-version=3",
#                 "name": "tiny"
#             }
#         ],
#         "participations": {
#             "href": "https://api.w3.org/users/f1ovb5rydm8s0go04oco0cgk0sow44w/participations"
#         },
#         "chair_of_groups": {
#             "href": "https://api.w3.org/users/f1ovb5rydm8s0go04oco0cgk0sow44w/chair-of-groups"
#         },
#         "team_contact_of_groups": {
#             "href": "https://api.w3.org/users/f1ovb5rydm8s0go04oco0cgk0sow44w/team-contact-of-groups"
#         }
#     }
# }

require_relative "account"
require_relative "photo"

module W3cApi
  module Models
    # User model representing a W3C user/participant
    class User < Lutaml::Hal::Resource
      attribute :id, :string
      attribute :name, :string
      attribute :link, :string
      attribute :given, :string
      attribute :family, :string
      attribute :discr, :string
      attribute :country_code, :string
      attribute :connected_accounts, Account, collection: true
      attribute :photos, Photo, collection: true

      hal_link :self, key: "self", realize_class: "User"
      hal_link :affiliations, key: "affiliations",
                              realize_class: "AffiliationIndex"
      hal_link :groups, key: "groups", realize_class: "GroupIndex"
      hal_link :specifications, key: "specifications",
                                realize_class: "SpecificationIndex"
      hal_link :participations, key: "participations",
                                realize_class: "ParticipationIndex"
      hal_link :chair_of_groups, key: "chair-of-groups",
                                 realize_class: "GroupIndex"
      hal_link :team_contact_of_groups, key: "team-contact-of-groups",
                                        realize_class: "GroupIndex"
      hal_link :photos, key: "photos", realize_class: "Photo", collection: true

      key_value do
        %i[
          id
          name
          link
          given
          family
          discr
          country_code
          connected_accounts
          photos
        ].each do |key|
          map key.to_s.tr("_", "-"), to: key
        end
      end

      def groups(client = nil)
        return nil unless client

        client.user_groups(id)
      end

      def specifications(client = nil)
        return nil unless client

        client.user_specifications(id)
      end
    end
  end
end
