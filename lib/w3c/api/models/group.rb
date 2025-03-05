# frozen_string_literal: true

require_relative 'base'
require_relative 'join_emails'
require_relative 'link'

# {
#     "id": 35422
#     "name": "Accessibility Guidelines Working Group"
#     "is_closed": false
#     "description": "The mission of the Accessibility Guidelines Working Group (AG WG) is to develop specifications to make content on the Web accessible for people with disabilities and to participate in the development and maintenance of implementation support materials for the Web Content Accessibility Guidelines."
#     "shortname": "ag"
#     "discr": "w3cgroup"
#     "_links": {
#         "self": {
#             "href": "https://api.w3.org/groups/wg/ag"
#         }
#         "homepage": {
#             "href": "https://www.w3.org/WAI/GL/"
#         }
#         "users": {
#             "href": "https://api.w3.org/groups/wg/ag/users"
#         }
#         "services": {
#             "href": "https://api.w3.org/groups/wg/ag/services"
#         }
#         "specifications": {
#             "href": "https://api.w3.org/groups/wg/ag/specifications"
#         }
#         "chairs": {
#             "href": "https://api.w3.org/groups/wg/ag/chairs"
#         }
#         "team-contacts": {
#             "href": "https://api.w3.org/groups/wg/ag/teamcontacts"
#         }
#         "charters": {
#             "href": "https://api.w3.org/groups/wg/ag/charters"
#         }
#         "active-charter": {
#             "href": "https://api.w3.org/groups/wg/ag/charters/492"
#         }
#         "join": {
#             "href": "https://www.w3.org/groups/wg/ag/join"
#         }
#         "pp-status": {
#             "href": "https://www.w3.org/groups/wg/ag/ipr"
#         }
#         "participations": {
#             "href": "https://api.w3.org/groups/wg/ag/participations"
#         }
#     }
#     "type": "working group"
#     "start-date": "1997-10-06"
#     "end-date": "2025-10-31"
# }

module W3c
  module Api
    module Models
      class GroupLinks < Lutaml::Model::Serializable
        attribute :self, Link
        attribute :homepage, Link
        attribute :users, Link
        attribute :services, Link
        attribute :specifications, Link
        attribute :chairs, Link
        attribute :team_contacts, Link
        attribute :charters, Link
        attribute :active_charter, Link
        attribute :join, Link
        attribute :pp_status, Link
        attribute :participations, Link
      end

      class Group < Base
        attribute :id, :integer
        attribute :name, :string
        attribute :type, :string
        attribute :href, :string
        attribute :title, :string
        attribute :description, :string
        attribute :shortname, :string
        attribute :shortlink, :string
        attribute :discr, :string
        attribute :created, :string # Date-time format
        attribute :start_date, :string # Date-time format
        attribute :end_date, :string # Date-time format
        attribute :is_closed, :boolean
        attribute :patent_policy, :string
        attribute :charter_closed, :boolean
        attribute :join_emails, JoinEmails
        attribute :_links, GroupLinks

        # Return users in this group
        def users(client = nil)
          return nil unless client && _links&.users

          client.group_users(id)
        end

        # Return specifications in this group
        def specifications(client = nil)
          return nil unless client && _links&.specifications

          client.group_specifications(id)
        end

        # Return charters for this group
        def charters(client = nil)
          return nil unless client && _links&.charters

          client.group_charters(id)
        end

        # Parse date strings to Date objects
        def created_date
          Date.parse(created) if created
        rescue Date::Error
          nil
        end

        def start_date_parsed
          Date.parse(start_date) if start_date
        rescue Date::Error
          nil
        end

        def end_date_parsed
          Date.parse(end_date) if end_date
        rescue Date::Error
          nil
        end

        # Check if this group is active
        def active?
          !is_closed && (!end_date || Date.parse(end_date) > Date.today)
        rescue Date::Error
          !is_closed
        end

        def self.from_response(response)
          transformed_response = transform_keys(response)

          group = new
          transformed_response.each do |key, value|
            case key
            when :_links
              links = value.each_with_object({}) do |(link_name, link_data), acc|
                acc[link_name] = Link.new(href: link_data[:href], title: link_data[:title])
              end
              group._links = GroupLinks.new(links)
            else
              group.send("#{key}=", value) if group.respond_to?("#{key}=")
            end
          end
          group
        end
      end
    end
  end
end
