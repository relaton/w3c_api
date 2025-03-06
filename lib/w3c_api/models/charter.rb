# frozen_string_literal: true

require_relative 'base'
require_relative 'extension'
require_relative 'link'

# Example charter response format - specific fields may vary by group:
# {
#     "end": "2025-10-31"
#     "title": "Accessibility Guidelines Working Group Charter"
#     "start": "1997-10-06"
#     "initial_end": "1999-10-06"
#     "uri": "https://www.w3.org/2022/05/accessibility-guidelines-wg-charter.html"
#     "cfp_uri": "https://lists.w3.org/Archives/Member/w3c-ac-members/..."
#     "extensions": [...]
#     "required_new_commitments": false
#     "patent_policy": "pre-2020"
#     "_links": {
#         "self": {
#             "href": "https://api.w3.org/groups/wg/ag/charters/492"
#         },
#         "group": {
#             "href": "https://api.w3.org/groups/wg/ag"
#         }
#     }
# }

module W3cApi
    module Models
      class CharterLinks < Lutaml::Model::Serializable
        attribute :self, Link
        attribute :group, Link
      end

      class Charter < Base
        attribute :end, :string # Date-time format
        attribute :href, :string
        attribute :title, :string
        attribute :start, :string # Date-time format
        attribute :initial_end, :string # Date-time format
        attribute :uri, :string, pattern: %r{https?://www\.w3\.org.*}
        attribute :cfp_uri, :string, pattern: %r{https://lists\.w3\.org/Archives/Member/w3c-ac-members/.*}
        attribute :extensions, Extension, collection: true
        attribute :required_new_commitments, :boolean
        attribute :patent_policy, :string
        attribute :_links, CharterLinks

        # Return the group this charter belongs to
        def group(client = nil)
          return nil unless client && _links&.group

          group_href = _links.group.href
          group_id = group_href.split('/').last

          client.group(group_id)
        end

        # Parse date strings to Date objects
        def end_date
          Date.parse(self.end) if self.end
        rescue Date::Error
          nil
        end

        def start_date
          Date.parse(start) if start
        rescue Date::Error
          nil
        end

        def initial_end_date
          Date.parse(initial_end) if initial_end
        rescue Date::Error
          nil
        end

        # Check if this charter is active
        def active?
          start_date &&
            (end_date.nil? || end_date >= Date.today) &&
            start_date <= Date.today
        rescue Date::Error
          false
        end

        # Check if this charter has been extended
        def extended?
          !extensions.nil? && !extensions.empty?
        end

        def self.from_response(response)
          transformed_response = transform_keys(response)

          charter = new
          transformed_response.each do |key, value|
            case key
            when :_links
              links = value.each_with_object({}) do |(link_name, link_data), acc|
                acc[link_name] = Link.new(href: link_data[:href], title: link_data[:title])
              end
              charter._links = CharterLinks.new(links)
            else
              charter.send("#{key}=", value) if charter.respond_to?("#{key}=")
            end
          end
          charter
        end
      end
    end
end
