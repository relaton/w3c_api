# frozen_string_literal: true

require 'lutaml/model'
require_relative 'affiliation'
require_relative 'delegate_enumerable'
require_relative 'collection_base'

# {
#   "page"=>1,
#   "limit"=>1000,
#   "pages"=>16,
#   "total"=>15918,
#   "_links"=>{
#     "affiliations"=>[
#       {
#         "href"=>"https://api.w3.org/affiliations/1001",
#         "title"=>"Framkom (Forskningsaktiebolaget Medie-och Kommunikationsteknik)"
#       },
#       {
#         "href"=>"https://api.w3.org/affiliations/1003",
#         "title"=>"BackWeb Technologies, Inc."
#       },

module W3c
  module Api
    module Models
      class Affiliations < CollectionBase
        attribute :affiliations, Affiliation, collection: true

        delegate_enumerable :affiliations
        collection_instance_class Affiliation, :affiliations
      end
    end
  end
end
