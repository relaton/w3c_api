# frozen_string_literal: true

require_relative 'base'
require_relative 'link'

# {
#     "name": "Data and knowledge"
#     "shortname": "data"
#     "_links": {
#         "self": {
#             "href": "https://api.w3.org/ecosystems/data"
#         }
#         "champion": {
#             "href": "https://api.w3.org/users/t891ludoisggsccsw44o8goccc0s0ks"
#             "title": "Pierre-Antoine Champin"
#         }
#         "evangelists": {
#             "href": "https://api.w3.org/ecosystems/data/evangelists"
#         }
#         "groups": {
#             "href": "https://api.w3.org/ecosystems/data/groups"
#         }
#         "member-organizations": {
#             "href": "https://api.w3.org/ecosystems/data/member-organizations"
#         }
#     }
# }

module W3c
  module Api
    module Models
      class EcosystemLinks < Lutaml::Model::Serializable
        attribute :self, Link
        attribute :champion, Link
        attribute :evangelists, Link
        attribute :groups, Link
        attribute :member_organizations, Link
      end

      class Ecosystem < Base
        attribute :name, :string
        attribute :shortname, :string
        attribute :href, :string
        attribute :title, :string
        attribute :_links, EcosystemLinks

        # Return groups in this ecosystem
        def groups(client = nil)
          return nil unless client && _links&.groups

          client.ecosystem_groups(shortname)
        end

        def self.from_response(response)
          transformed_response = transform_keys(response)

          ecosystem = new
          transformed_response.each do |key, value|
            case key
            when :_links
              links = value.each_with_object({}) do |(link_name, link_data), acc|
                acc[link_name] = Link.new(href: link_data[:href], title: link_data[:title])
              end
              ecosystem._links = EcosystemLinks.new(links)
            else
              ecosystem.send("#{key}=", value) if ecosystem.respond_to?("#{key}=")
            end
          end
          ecosystem
        end
      end
    end
  end
end
