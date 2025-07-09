# frozen_string_literal: true

require "lutaml/hal"

#     "testimonials": {
#         "en": "Google's mission is to organize the world’s information and make it universally accessible and useful."
#     },

module W3cApi
  module Models
    class Testimonial < Lutaml::Hal::Resource
      attribute :en, :string

      key_value do
        map "en", to: :en
      end
    end
  end
end
