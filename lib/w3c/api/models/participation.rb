# frozen_string_literal: true

require_relative 'base'
require_relative 'link'

# Example participation response:
# {
#     "created": "2023-01-01T12:00:00Z",
#     "_links": {
#         "self": {
#             "href": "https://api.w3.org/participations/123"
#         },
#         "group": {
#             "href": "https://api.w3.org/groups/456",
#             "title": "Example Group"
#         },
#         "user": {
#             "href": "https://api.w3.org/users/789",
#             "title": "John Doe"
#         },
#         "organization": {
#             "href": "https://api.w3.org/affiliations/101",
#             "title": "Example Organization"
#         },
#         "participants": {
#             "href": "https://api.w3.org/participations/123/participants"
#         }
#     }
# }

module W3c
  module Api
    module Models
      class ParticipationLinks < Lutaml::Model::Serializable
        attribute :self, Link
        attribute :group, Link
        attribute :user, Link
        attribute :organization, Link
        attribute :participants, Link
      end

      class Participation < Base
        attribute :title, :string
        attribute :href, :string
        attribute :created, :date_time # Date-time format
        attribute :_links, ParticipationLinks

        # Parse date strings to Date objects
        def created_date
          Date.parse(created) if created
        rescue Date::Error
          nil
        end

        # Get the group this participation is for
        def group(client = nil)
          return nil unless client && _links&.group

          href = _links.group.href
          id = href.split('/').last
          client.group(id)
        end

        # Get the user participating
        def user(client = nil)
          return nil unless client && _links&.user

          href = _links.user.href
          id = href.split('/').last
          client.user(id)
        end

        # Get the organization participating
        def organization(client = nil)
          return nil unless client && _links&.organization

          href = _links.organization.href
          id = href.split('/').last
          client.affiliation(id)
        end

        # Get participants in this participation
        def participants(client = nil)
          return nil unless client && _links&.participants

          href = _links.participants.href
          id = href.split('/').last
          client.participation_participants(id)
        end

        def self.from_response(response)
          transformed_response = transform_keys(response)

          participation = new
          transformed_response.each do |key, value|
            case key
            when :_links
              links = value.each_with_object({}) do |(link_name, link_data), acc|
                acc[link_name] = Link.new(href: link_data[:href], title: link_data[:title])
              end
              participation._links = ParticipationLinks.new(links)
            else
              participation.send("#{key}=", value) if participation.respond_to?("#{key}=")
            end
          end
          participation
        end
      end
    end
  end
end
