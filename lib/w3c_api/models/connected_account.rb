# frozen_string_literal: true

# {
#   "created"=>"2019-07-18T21:28:31+00:00",
#   "updated"=>"2021-01-21T10:49:57+00:00",
#   "service"=>"github",
#   "identifier"=>"1801875",
#   "nickname"=>"davidsgrogan",
#   "profile-picture"=>"https://avatars.githubusercontent.com/u/1801875?v=4",
#   "href"=>"https://github.com/davidsgrogan",
#   "_links"=>{
#     "user"=>{
#       "href"=>"https://api.w3.org/users/c2yerd5euz48gcw08s44oww8g4oo8w8"
#     }
#   }
# }

module W3cApi
  module Models
    class ConnectedAccount < Lutaml::Hal::Resource
      attribute :created, :date_time
      attribute :updated, :date_time
      attribute :service, :string
      attribute :identifier, :string
      attribute :nickname, :string
      attribute :profile_picture, :string
      attribute :href, :string

      hal_link :user, key: "user", realize_class: "User"

      key_value do
        %i[
          created
          updated
          service
          identifier
          nickname
          profile_picture
        ].each do |key|
          map key.to_s.tr("_", "-"), to: key
        end
      end
    end
  end
end
