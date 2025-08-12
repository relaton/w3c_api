# frozen_string_literal: true

# https://api.w3.org/specifications/html5
# {
#     "shortlink": "https://www.w3.org/TR/html5/",
#     "description": "<p>This specification defines the 5th major revision of the core language of the World Wide Web: the Hypertext Markup Language (HTML). " \
#                    "In this version, new features are introduced to help Web application authors, new elements are introduced based on research " \
#                    "into prevailing authoring practices, " \
#                    "and special attention has been given to defining clear conformance criteria for user agents in an effort to improve interoperability.</p>",
#     "title": "HTML5",
#     "shortname": "html5",
#     "series-version": "5",
#     "_links": {
#         "self": {
#             "href": "https://api.w3.org/specifications/html5"
#         },
#         "version-history": {
#             "href": "https://api.w3.org/specifications/html5/versions"
#         },
#         "first-version": {
#             "href": "https://api.w3.org/specifications/html5/versions/20080122",
#             "title": "Working Draft"
#         },
#         "latest-version": {
#             "href": "https://api.w3.org/specifications/html5/versions/20180327",
#             "title": "Retired"
#         },
#         "supersedes": {
#             "href": "https://api.w3.org/specifications/html5/supersedes"
#         },
#         "series": {
#             "href": "https://api.w3.org/specification-series/html"
#         }
#     }
# }

module W3cApi
  module Models
    class Specification < Lutaml::Hal::Resource
      attribute :shortlink, :string
      attribute :description, :string
      attribute :title, :string
      attribute :href, :string
      attribute :shortname, :string
      attribute :editor_draft, :string
      attribute :series_version, :string

      hal_link :self, key: "self", realize_class: "Specification"
      hal_link :version_history, key: "version-history",
                                 realize_class: "SpecVersionIndex"
      hal_link :first_version, key: "first-version",
                               realize_class: "SpecVersion"
      hal_link :latest_version, key: "latest-version",
                                realize_class: "SpecVersion"
      hal_link :supersedes, key: "supersedes",
                            realize_class: "SpecificationIndex", collection: true
      hal_link :series, key: "series", realize_class: "Serie"

      key_value do
        %i[
          shortlink
          description
          title
          href
          shortname
          editor_draft
          series_version
        ].each do |key|
          map key.to_s.tr("_", "-"), to: key
        end
      end

      def versions(client = nil)
        return nil unless client

        client.specification_versions(shortname)
      end
    end
  end
end
