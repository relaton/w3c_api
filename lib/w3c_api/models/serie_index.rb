# frozen_string_literal: true

require_relative "serie"

# https://api.w3.org/specification-series
# {
#   "page": 1,
#   "limit": 100,
#   "pages": 15,
#   "total": 1426,
#   "_links": {
#     "specification-series": [
#       {
#         "href": "https://api.w3.org/specification-series/2dcontext",
#         "title": "2dcontext"
#       },
#       {
#         "href": "https://api.w3.org/specification-series/abstract-ui",
#         "title": "abstract-ui"
#       },
#       {
#         "href": "https://api.w3.org/specification-series/cors",
#         "title": "cors"
#       },
#       {
#         "href": "https://api.w3.org/specification-series/accessibility-metrics-report",
#         "title": "accessibility-metrics-report"
#       },
#     ],
#     "self": {
#         "href": "https://api.w3.org/specification-series?page=1&items=100"
#     },
#     "first": {
#         "href": "https://api.w3.org/specification-series?page=1&items=100"
#     },
#     "last": {
#         "href": "https://api.w3.org/specification-series?page=15&items=100"
#     },
#     "next": {
#         "href": "https://api.w3.org/specification-series?page=2&items=100"
#     }
#   }
# }
module W3cApi
  module Models
    class SerieIndex < Lutaml::Hal::Page
      hal_link :series, key: "specification-series", realize_class: "Serie",
                        collection: true
    end
  end
end
