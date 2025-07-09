# frozen_string_literal: true

# {
#     "name": "Data and knowledge"
#     "shortname": "data"
#     "_links": {
#         "self": {
#             "href": "https://api.w3.org/ecosystems/data"
#         }
#         "champion": {
#             "href": "https://api.w3.org/users/t891ludoisggsccsw44o8goccc0s0ks"
#             "title": "Pierre-Antoine Champin"
#         }
#         "evangelists": {
#             "href": "https://api.w3.org/ecosystems/data/evangelists"
#         }
#         "groups": {
#             "href": "https://api.w3.org/ecosystems/data/groups"
#         }
#         "member-organizations": {
#             "href": "https://api.w3.org/ecosystems/data/member-organizations"
#         }
#     }
# }

module W3cApi
  module Models
    class Ecosystem < Lutaml::Hal::Resource
      attribute :name, :string
      attribute :shortname, :string
      attribute :href, :string
      attribute :title, :string

      hal_link :self, key: "self", realize_class: "Ecosystem"
      hal_link :champion, key: "champion", realize_class: "User"
      hal_link :evangelists, key: "evangelists",
                             realize_class: "EvangelistIndex"
      hal_link :groups, key: "groups", realize_class: "GroupIndex"
      hal_link :member_organizations, key: "member-organizations",
                                      realize_class: "AffiliationIndex"

      key_value do
        %i[
          name
          shortname
        ].each do |key|
          map key.to_s.tr("_", "-"), to: key
        end
      end
    end
  end
end
