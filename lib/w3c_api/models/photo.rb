# frozen_string_literal: true

require "lutaml/model"

#         "photos": [
#             {
#                 "href": "https://www.w3.org/thumbnails/360/avatar-images/f1ovb5rydm8s0go04oco0cgk0sow44w.webp?x-version=3",
#                 "name": "large"
#             },

module W3cApi
  module Models
    # User model representing a W3C user/participant
    class Photo < Lutaml::Model::Serializable
      attribute :href, :string
      attribute :name, :string

      key_value do
        %i[
          href
          name
        ].each do |key|
          map key.to_s, to: key
        end
      end
    end
  end
end
