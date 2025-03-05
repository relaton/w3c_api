# frozen_string_literal: true

require 'lutaml/model'
require_relative 'ecosystem'
require_relative 'delegate_enumerable'
require_relative 'collection_base'

# {
#   "page": 1,
#   "limit": 100,
#   "pages": 1,
#   "total": 9,
#   "_links": {
#     "ecosystems": [
#       {
#         "href": "https://api.w3.org/ecosystems/advertising",
#         "title": "Web Advertising"
#       },
#       {
#         "href": "https://api.w3.org/ecosystems/e-commerce",
#         "title": "E-commerce"
#       },

module W3c
  module Api
    module Models
      class Ecosystems < CollectionBase
        attribute :ecosystems, Ecosystem, collection: true

        delegate_enumerable :ecosystems
        collection_instance_class Ecosystem, :ecosystems
      end
    end
  end
end
