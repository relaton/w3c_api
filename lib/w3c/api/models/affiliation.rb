# frozen_string_literal: true

require_relative 'base'
require_relative 'link'

# Example affiliation response:
# {
#   "id"=>48830,
#   "name"=>"Postmedia",
#   "discr"=>"organization",
#   "is-member"=>false,
#   "is-member-association"=>false,
#   "is-partner-member"=>false,
#   "_links"=>{
#     "self"=>{
#       "href"=>"https://api.w3.org/affiliations/48830"
#     },
#     "participants"=>{
#       "href"=>"https://api.w3.org/affiliations/48830/participants"
#     },
#     "participations"=>{
#       "href"=>"https://api.w3.org/affiliations/48830/participations"
#     }
#   }
# }

# Fetch index response:
# {
#   "href"=>"https://api.w3.org/affiliations/1001",
#   "title"=>"Framkom (Forskningsaktiebolaget Medie-och Kommunikationsteknik)"
# },


module W3c
  module Api
    module Models
      class AffiliationLinks < Lutaml::Model::Serializable
        attribute :self, Link
        attribute :participants, Link
        attribute :participations, Link
      end

      class Affiliation < Base
        attribute :id, :integer
        attribute :name, :string
        attribute :href, :string
        attribute :title, :string
        attribute :descr, :string
        attribute :is_member, :boolean
        attribute :is_member_association, :boolean
        attribute :is_partner_member, :boolean
        attribute :_links, AffiliationLinks

        # Get participants of this affiliation
        def participants(client = nil)
          return nil unless client && _links&.participants

          client.affiliation_participants(id)
        end

        # Get participations of this affiliation
        def participations(client = nil)
          return nil unless client && _links&.participations

          client.affiliation_participations(id)
        end

        def self.from_response(response)
          transformed_response = transform_keys(response)

          affiliation = new
          transformed_response.each do |key, value|
            case key
            when :_links
              links = value.each_with_object({}) do |(link_name, link_data), acc|
                acc[link_name] = Link.new(href: link_data[:href], title: link_data[:title])
              end
              affiliation._links = AffiliationLinks.new(links)
            else
              affiliation.send("#{key}=", value) if affiliation.respond_to?("#{key}=")
            end
          end
          affiliation
        end
      end
    end
  end
end
