# frozen_string_literal: true

# https://api.w3.org/participations/38785
# {
#     "individual": false,
#     "invited-expert": false,
#     "created": "2022-11-17 22:54:08",
#     "_links": {
#         "self": {
#             "href": "https://api.w3.org/participations/38785"
#         },
#         "group": {
#             "href": "https://api.w3.org/groups/cg/silver",
#             "title": "Silver Community Group"
#         },
#         "organization": {
#             "href": "https://api.w3.org/affiliations/1092",
#             "title": "MITRE Corporation"
#         },
#         "participants": {
#             "href": "https://api.w3.org/participations/38785/participants"
#         }
#     }
# }
module W3cApi
  module Models
    class Participation < Lutaml::Hal::Resource
      attribute :title, :string
      attribute :href, :string
      attribute :created, :date_time
      attribute :individual, :boolean
      attribute :invited_expert, :boolean

      hal_link :self, key: "self", realize_class: "Participation"
      hal_link :group, key: "group", realize_class: "Group"
      hal_link :organization, key: "organization", realize_class: "Affiliation"
      hal_link :participants, key: "participants",
                              realize_class: "ParticipantIndex"

      key_value do
        %i[
          individual
          invited_expert
          created
        ].each do |key|
          map key.to_s.tr("_", "-"), to: key
        end
      end
    end
  end
end
