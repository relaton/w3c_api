# frozen_string_literal: true

require 'lutaml/model'
require_relative 'serie'
require_relative 'delegate_enumerable'
require_relative 'collection_base'

# {
#   "page": 1,
#   "limit": 1000,
#   "pages": 2,
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

module W3c
  module Api
    module Models
      class Series < CollectionBase
        attribute :series, Serie, collection: true

        delegate_enumerable :series
        collection_instance_class Serie, :series
      end
    end
  end
end
