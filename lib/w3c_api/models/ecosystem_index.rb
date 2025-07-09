# frozen_string_literal: true

require_relative "ecosystem"

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

module W3cApi
  module Models
    class EcosystemIndex < Lutaml::Hal::Page
      hal_link :ecosystems, key: "ecosystems", realize_class: "Ecosystem",
                            collection: true
    end
  end
end
