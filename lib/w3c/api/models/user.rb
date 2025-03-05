# frozen_string_literal: true

require_relative 'base'
require_relative 'connected_account'
require_relative 'link'

# {
#   "id"=>58291,
#   "name"=>"David Grogan",
#   "given"=>"David",
#   "family"=>"Grogan",
#   "work-title"=>"Software Engineer",
#   "connected-accounts"=>[
#     {
#       "created"=>"2019-07-18T21:28:31+00:00",
#       "updated"=>"2021-01-21T10:49:57+00:00",
#       "service"=>"github",
#       "identifier"=>"1801875",
#       "nickname"=>"davidsgrogan",
#       "profile-picture"=>"https://avatars.githubusercontent.com/u/1801875?v=4",
#       "href"=>"https://github.com/davidsgrogan",
#       "_links"=>{
#         "user"=>{
#           "href"=>"https://api.w3.org/users/c2yerd5euz48gcw08s44oww8g4oo8w8"
#         }
#       }
#     }
#   ],
#   "discr"=>"user",
#   "_links"=>{
#     "self"=>{
#       "href"=>"https://api.w3.org/users/c2yerd5euz48gcw08s44oww8g4oo8w8"
#     },
#     "affiliations"=>{
#       "href"=>"https://api.w3.org/users/c2yerd5euz48gcw08s44oww8g4oo8w8/affiliations"
#     },
#     "groups"=>{
#       "href"=>"https://api.w3.org/users/c2yerd5euz48gcw08s44oww8g4oo8w8/groups"
#     },
#     "specifications"=>{
#       "href"=>"https://api.w3.org/users/c2yerd5euz48gcw08s44oww8g4oo8w8/specifications"
#     },
#     "participations"=>{
#       "href"=>"https://api.w3.org/users/c2yerd5euz48gcw08s44oww8g4oo8w8/participations"
#     },
#     "chair_of_groups"=>{
#       "href"=>"https://api.w3.org/users/c2yerd5euz48gcw08s44oww8g4oo8w8/chair-of-groups"
#     },
#     "team_contact_of_groups"=>{
#       "href"=>"https://api.w3.org/users/c2yerd5euz48gcw08s44oww8g4oo8w8/team-contact-of-groups"
#     }
#   }
# }

# {
#   "id": 40757,
#   "name": "Stéphane Deschamps",
#   "given": "Stéphane",
#   "family": "Deschamps",
#   "work_title": "Mr.",
#   "discr": "user",
#   "biography": "I love accessibility and standards. Don't we all.",
#   "country_code": "FR",
#   "city": "Arcueil Cedex",
#   "_links": {
#     "self": {
#       "href": "https://api.w3.org/users/56nw1z8a5uo0sscsgk4kso8g0004008"
#     },
#     "affiliations": {
#       "href": "https://api.w3.org/users/56nw1z8a5uo0sscsgk4kso8g0004008/affiliations"
#     },
#     "groups": {
#       "href": "https://api.w3.org/users/56nw1z8a5uo0sscsgk4kso8g0004008/groups"
#     },
#     "specifications": {
#       "href": "https://api.w3.org/users/56nw1z8a5uo0sscsgk4kso8g0004008/specifications"
#     },
#     "participations": {
#       "href": "https://api.w3.org/users/56nw1z8a5uo0sscsgk4kso8g0004008/participations"
#     },
#     "chair_of_groups": {
#       "href": "https://api.w3.org/users/56nw1z8a5uo0sscsgk4kso8g0004008/chair-of-groups"
#     },
#     "team_contact_of_groups": {
#       "href": "https://api.w3.org/users/56nw1z8a5uo0sscsgk4kso8g0004008/team-contact-of-groups"
#     }
#   }
# }

module W3c
  module Api
    module Models
      class UserPhoto < Lutaml::Model::Serializable
        attribute :href, :string
        attribute :name, :string
      end

      class UserLinks < Lutaml::Model::Serializable
        attribute :self, Link
        attribute :affiliations, Link
        attribute :groups, Link
        attribute :specifications, Link
        attribute :participations, Link
        attribute :chair_of_groups, Link
        attribute :team_contact_of_groups, Link
      end

      class User < Base
        attribute :id, :integer
        attribute :href, :string
        attribute :title, :string
        attribute :name, :string
        attribute :email, :string
        attribute :given, :string
        attribute :family, :string
        attribute :work_title, :string
        attribute :discr, :string
        attribute :biography, :string
        attribute :phone, :string
        attribute :country_code, :string
        attribute :country_division, :string
        attribute :city, :string
        attribute :connected_accounts, ConnectedAccount, collection: true
        attribute :_links, UserLinks

        # Return groups this user is a member of
        def groups(client = nil)
          return nil unless client && _links&.groups

          client.user_groups(id)
        end

        # Return specifications this user has contributed to
        def specifications(client = nil)
          return nil unless client && _links&.specifications

          client.user_specifications(id)
        end

        def self.from_response(response)
          transformed_response = transform_keys(response)

          user = new
          transformed_response.each do |key, value|
            case key
            when :connected_accounts
              user.connected_accounts = value.map do |account|
                ConnectedAccount.from_response(account)
              end
            when :_links
              links_data = {}

              # Handle all standard links
              value.each do |link_name, link_data|
                next if link_name == :photos

                # Handle photos array separately

                links_data[link_name] = Link.new(href: link_data[:href], title: link_data[:title])
              end

              # Handle photos if present
              if value[:photos]
                photos = value[:photos].map do |photo|
                  UserPhoto.new(href: photo[:href], name: photo[:name])
                end
                links_data[:photos] = photos
              end

              user._links = UserLinks.new(links_data)
            else
              user.send("#{key}=", value) if user.respond_to?("#{key}=")
            end
          end
          user
        end
      end
    end
  end
end
