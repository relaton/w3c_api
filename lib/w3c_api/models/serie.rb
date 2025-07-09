# frozen_string_literal: true

# https://api.w3.org/specification-series/css-backgrounds
# {
#     "shortname": "css-backgrounds",
#     "name": "CSS Backgrounds and Borders",
#     "_links": {
#         "self": {
#             "href": "https://api.w3.org/specification-series/css-backgrounds"
#         },
#         "specifications": {
#             "href": "https://api.w3.org/specification-series/css-backgrounds/specifications"
#         },
#         "current-specification": {
#             "href": "https://api.w3.org/specifications/css-backgrounds-3"
#         }
#     }
# }

# {
#   "shortname": "2dcontext",
#   "name": "HTML Canvas 2D Context",
#   "_links": {
#     "self": {
#       "href": "https://api.w3.org/specification-series/2dcontext"
#     },
#     "specifications": {
#       "href": "https://api.w3.org/specification-series/2dcontext/specifications"
#     },
#     "current-specification": {
#       "href": "https://api.w3.org/specifications/2dcontext"
#     }
#   }
# }

module W3cApi
  module Models
    class Serie < Lutaml::Hal::Resource
      attribute :shortname, :string
      attribute :name, :string
      attribute :href, :string
      attribute :title, :string

      hal_link :self, key: "self", realize_class: "Serie"
      hal_link :specifications, key: "specifications",
                                realize_class: "SpecificationIndex"
      hal_link :current_specification, key: "current-specification",
                                       realize_class: "SpecVersion"

      key_value do
        %i[
          shortname
          name
        ].each do |key|
          map key.to_s.tr("_", "-"), to: key
        end
      end

      def specifications(client = nil)
        return nil unless client

        client.series_specifications(shortname)
      end

      def current_specification(client = nil)
        return nil unless client

        client.specification(shortname)
      end
    end
  end
end
