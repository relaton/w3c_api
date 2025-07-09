# frozen_string_literal: true

# https://api.w3.org/affiliations/35662
# {
#     "id": 35662,
#     "name": "Google LLC",
#     "discr": "organization",
#     "testimonials": {
#         "en": "Google's mission is to organize the world’s information and make it universally accessible and useful."
#     },
#     "is-member": true,
#     "is-member-association": false,
#     "is-partner-member": false,
#     "_links": {
#         "homepage": {
#             "href": "http://www.google.com/"
#         },
#         "self": {
#             "href": "https://api.w3.org/affiliations/35662"
#         },
#         "participants": {
#             "href": "https://api.w3.org/affiliations/35662/participants"
#         },
#         "participations": {
#             "href": "https://api.w3.org/affiliations/35662/participations"
#         },
#         "logo": {
#             "href": "https://www.w3.org/thumbnails/250/logos/organizations/35662.png?x-version=1"
#         }
#     }
# }

# Fetch index response:
# {
#   "href"=>"https://api.w3.org/affiliations/1001",
#   "title"=>"Framkom (Forskningsaktiebolaget Medie-och Kommunikationsteknik)"
# },

require_relative "testimonial"

module W3cApi
  module Models
    class Affiliation < Lutaml::Hal::Resource
      attribute :id, :integer
      attribute :name, :string
      attribute :href, :string
      attribute :title, :string
      attribute :discr, :string
      attribute :testimonials, Testimonial
      attribute :is_member, :boolean
      attribute :is_member_association, :boolean
      attribute :is_partner_member, :boolean

      hal_link :self, key: "self", realize_class: "Affiliation"
      hal_link :homepage, key: "homepage", realize_class: "String"
      hal_link :participants, key: "participants", realize_class: "Participant"
      hal_link :participations, key: "participations",
                                realize_class: "Participation"
      hal_link :logo, key: "logo", realize_class: "String"

      key_value do
        %i[
          id
          name
          discr
          testimonials
          is_member
          is_member_association
          is_partner_member
        ].each do |key|
          map key.to_s.tr("_", "-"), to: key
        end
      end

      def participants(client = nil)
        return nil unless client

        client.affiliation_participants(id)
      end

      def participations(client = nil)
        return nil unless client

        client.affiliation_participations(id)
      end
    end
  end
end
