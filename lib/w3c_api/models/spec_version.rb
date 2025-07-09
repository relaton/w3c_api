# frozen_string_literal: true

# https://api.w3.org/specifications/html5/versions/20180327
# {
#     "status": "Retired",
#     "rec-track": true,
#     "uri": "https://www.w3.org/TR/2018/SPSD-html5-20180327/",
#     "date": "2018-03-27",
#     "informative": false,
#     "title": "HTML5",
#     "shortlink": "https://www.w3.org/TR/html5/",
#     "_links": {
#         "self": {
#             "href": "https://api.w3.org/specifications/html5/versions/20180327"
#         },
#         "editors": {
#             "href": "https://api.w3.org/specifications/html5/versions/20180327/editors"
#         },
#         "deliverers": {
#             "href": "https://api.w3.org/specifications/html5/versions/20180327/deliverers"
#         },
#         "specification": {
#             "href": "https://api.w3.org/specifications/html5"
#         },
#         "predecessor-version": {
#             "href": "https://api.w3.org/specifications/html5/versions/20180327/predecessors"
#         }
#     }
# }

module W3cApi
  module Models
    class SpecVersion < Lutaml::Hal::Resource
      attribute :status, :string
      attribute :rec_track, :boolean
      attribute :editor_draft, :string
      attribute :uri, :string
      attribute :date, :date_time
      attribute :last_call_feedback_due, :date_time
      attribute :pr_reviews_date, :date_time
      attribute :implementation_feedback_due, :date_time
      attribute :per_reviews_due, :date_time
      attribute :informative, :boolean
      attribute :title, :string
      attribute :href, :string
      attribute :shortlink, :string
      attribute :translation, :string
      attribute :errata, :string
      attribute :process_rules, :string

      hal_link :self, key: "self", realize_class: "SpecVersion"
      hal_link :editors, key: "editors", realize_class: "EditorIndex"
      hal_link :deliverers, key: "deliverers", realize_class: "DelivererIndex"
      hal_link :specification, key: "specification",
                               realize_class: "Specification"
      hal_link :predecessor_versions, key: "predecessor-version",
                                      realize_class: "SpecVersionPredecessorIndex"
      hal_link :successor_versions, key: "successor-version",
                                    realize_class: "SpecVersionSuccessorIndex"

      key_value do
        %i[
          status
          rec_track
          editor_draft
          uri
          date
          last_call_feedback_due
          pr_reviews_date
          implementation_feedback_due
          per_reviews_due
          informative
          title
          href
          shortlink
          translation
          errata
          process_rules
        ].each do |key|
          map key.to_s.tr("_", "-"), to: key
        end
      end
    end
  end
end
