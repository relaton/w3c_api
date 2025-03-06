# frozen_string_literal: true

require 'lutaml/model'

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
      class ConnectedAccountLinks < Lutaml::Model::Serializable
        attribute :user, Link
      end

      class ConnectedAccount < Base
        attribute :created, :date_time
        attribute :updated, :date_time
        attribute :service, :string
        attribute :identifier, :string
        attribute :nickname, :string
        attribute :profile_picture, :string
        attribute :href, :string
        attribute :_links, ConnectedAccountLinks

        def self.from_response(response)
          transformed_response = transform_keys(response)
          account = new
          transformed_response.each do |key, value|
            case key
            when :_links
              links = value.each_with_object({}) do |(link_name, link_data), acc|
                acc[link_name] = Link.new(href: link_data[:href], title: link_data[:title])
              end
              account._links = ConnectedAccountLinks.new(links)
            else
              account.send("#{key}=", value) if account.respond_to?("#{key}=")
            end
          end
          account
        end
      end
    end
end
