# frozen_string_literal: true

require "lutaml/hal"
#         {
#             "created": "2021-03-12T22:06:06+00:00",
#             "service": "github",
#             "identifier": "57469",
#             "nickname": "jenstrickland",
#             "profile-picture": "https://avatars.githubusercontent.com/u/57469?v=4",
#             "href": "https://github.com/jenstrickland",
#             "_links": {
#                 "user": {
#                     "href": "https://api.w3.org/users/f1ovb5rydm8s0go04oco0cgk0sow44w"
#                 }
#             }
#         }

module W3cApi
  module Models
    # User model representing a W3C user/participant
    class Account < Lutaml::Hal::Resource
      attribute :created, :date_time
      attribute :updated, :date_time
      attribute :identifier, :string
      attribute :nickname, :string
      attribute :service, :string
      attribute :profile_picture, :string
      attribute :href, :string

      hal_link :user, key: "user", realize_class: "User"

      key_value do
        %i[
          created
          updated
          identifier
          nickname
          service
          profile_picture
        ].each do |key|
          map key.to_s.tr("_", "-"), to: key
        end
      end
    end
  end
end
