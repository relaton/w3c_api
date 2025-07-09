# frozen_string_literal: true

require_relative "extension"

# https://api.w3.org/groups/109735/charters/361
# {
#     "end": "2020-04-30",
#     "doc-licenses": [],
#     "start": "2018-09-24",
#     "initial-end": "2020-03-01",
#     "uri": "https://www.w3.org/2018/09/immersive-web-wg-charter.html",
#     "cfp-uri": "https://lists.w3.org/Archives/Member/w3c-ac-members/2018JulSep/0053.html",
#     "extensions": [
#         {
#             "end": "2020-04-30",
#             "announcement_uri": "https://lists.w3.org/Archives/Member/w3c-ac-members/2020JanMar/0028.html"
#         }
#     ],
#     "required-new-commitments": true,
#     "patent-policy": "https://www.w3.org/Consortium/Patent-Policy-20170801/",
#     "_links": {
#         "self": {
#             "href": "https://api.w3.org/groups/wg/immersive-web/charters/361"
#         },
#         "group": {
#             "href": "https://api.w3.org/groups/wg/immersive-web",
#             "title": "Immersive Web Working Group"
#         },
#         "next-charter": {
#             "href": "https://api.w3.org/groups/wg/immersive-web/charters/405"
#         }
#     }
# }

module W3cApi
  module Models
    class Charter < Lutaml::Hal::Resource
      attribute :end, :date_time
      attribute :doc_licenses, :string, collection: true
      attribute :start, :date_time
      attribute :initial_end, :date_time
      attribute :uri, :string
      attribute :cfp_uri, :string
      attribute :extensions, Extension, collection: true
      attribute :required_new_commitments, :boolean
      attribute :patent_policy, :string

      hal_link :self, key: "self", realize_class: "Charter"
      hal_link :group, key: "group", realize_class: "Group"
      hal_link :next_charter, key: "next-charter", realize_class: "Charter"

      key_value do
        %i[
          end
          doc_licenses
          start
          initial_end
          uri
          cfp_uri
          extensions
          required_new_commitments
          patent_policy
        ].each do |key|
          map key.to_s.tr("_", "-"), to: key
        end
      end
    end
  end
end
