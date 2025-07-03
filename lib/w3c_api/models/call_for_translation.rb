# frozen_string_literal: true

# {
#     "uri": "https://www.w3.org/WAI/videos/standards-and-benefits/"
#     "title": "Video Introduction to Web Accessibility and W3C Standards"
#     "_links": {
#         "self": {
#             "href": "https://api.w3.org/callsfortranslation/5"
#         }
#         "translations": {
#             "href": "https://api.w3.org/callsfortranslation/5/translations"
#         }
#     }
# }

module W3cApi
  module Models
    class CallForTranslation < Lutaml::Hal::Resource
      attribute :uri, :string
      attribute :title, :string

      hal_link :self, key: "self", realize_class: "CallForTranslation"
      hal_link :translations, key: "translations",
                              realize_class: "TranslationIndex"

      key_value do
        %i[
          uri
          title
        ].each do |key|
          map key.to_s.tr("_", "-"), to: key
        end
      end
    end
  end
end
