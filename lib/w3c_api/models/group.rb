# frozen_string_literal: true

# https://api.w3.org/groups/109735
# {
#     "id": 109735,
#     "name": "Immersive Web Working Group",
#     "is_closed": false,
#     "description": "The mission of the Immersive Web Working Group is to help bring high-performance Virtual Reality (VR) and Augmented Reality (AR) " \
#                    "(collectively known as XR) to the open Web via APIs to interact with XR devices and sensors in browsers.",
#     "shortname": "immersive-web",
#     "discr": "w3cgroup",
#     "_links": {
#         "self": {
#             "href": "https://api.w3.org/groups/wg/immersive-web"
#         },
#         "homepage": {
#             "href": "https://www.w3.org/immersive-web/"
#         },
#         "users": {
#             "href": "https://api.w3.org/groups/wg/immersive-web/users"
#         },
#         "services": {
#             "href": "https://api.w3.org/groups/wg/immersive-web/services"
#         },
#         "specifications": {
#             "href": "https://api.w3.org/groups/wg/immersive-web/specifications"
#         },
#         "chairs": {
#             "href": "https://api.w3.org/groups/wg/immersive-web/chairs"
#         },
#         "team-contacts": {
#             "href": "https://api.w3.org/groups/wg/immersive-web/teamcontacts"
#         },
#         "charters": {
#             "href": "https://api.w3.org/groups/wg/immersive-web/charters"
#         },
#         "active-charter": {
#             "href": "https://api.w3.org/groups/wg/immersive-web/charters/514"
#         },
#         "join": {
#             "href": "https://www.w3.org/groups/wg/immersive-web/join"
#         },
#         "pp-status": {
#             "href": "https://www.w3.org/groups/wg/immersive-web/ipr"
#         },
#         "participations": {
#             "href": "https://api.w3.org/groups/wg/immersive-web/participations"
#         }
#     },
#     "type": "working group",
#     "start-date": "2018-09-24",
#     "end-date": "2026-09-25"
# }

module W3cApi
  module Models
    # Group model representing a W3C working group
    class Group < Lutaml::Hal::Resource
      attribute :id, :integer
      attribute :type, :string
      attribute :name, :string
      attribute :is_closed, :boolean
      attribute :description, :string
      attribute :shortname, :string
      attribute :discr, :string

      hal_link :self, key: "self", realize_class: "Group"
      hal_link :homepage, key: "homepage", realize_class: "String"
      hal_link :users, key: "users", realize_class: "UserIndex"
      # hal_link :services, key: 'services', realize_class: 'ServiceIndex'
      hal_link :specifications, key: "specifications",
                                realize_class: "SpecificationIndex"
      hal_link :chairs, key: "chairs", realize_class: "UserIndex"
      hal_link :team_contacts, key: "team-contacts", realize_class: "UserIndex"
      hal_link :charters, key: "charters", realize_class: "CharterIndex"
      hal_link :active_charters, key: "active-charter", realize_class: "Charter"
      hal_link :join, key: "join", realize_class: "String"
      hal_link :pp_status, key: "pp-status", realize_class: "String"
      hal_link :participations, key: "participations",
                                realize_class: "ParticipationIndex"

      key_value do
        %i[
          id
          type
          name
          is_closed
          description
          shortname
          discr
        ].each do |key|
          map key.to_s.tr("_", "-"), to: key
        end
      end

      def users(client = nil)
        return nil unless client

        client.group_users(id)
      end

      def specifications(client = nil)
        return nil unless client

        client.group_specifications(id)
      end

      def chairs(client = nil)
        return nil unless client

        client.group_chairs(id)
      end

      def team_contacts(client = nil)
        return nil unless client

        client.group_team_contacts(id)
      end
    end
  end
end
