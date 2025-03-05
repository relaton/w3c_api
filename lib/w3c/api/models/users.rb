# frozen_string_literal: true

require 'lutaml/model'
require_relative 'user'
require_relative 'delegate_enumerable'
require_relative 'collection_base'

# {
# "page"=>1,
# "limit"=>100,
# "pages"=>8,
# "total"=>709,
# "_links"=>{
#   "up"=>{
#     "href"=>"https://api.w3.org/affiliations/35662"
#   },
#   "participants"=>[
#     {
#       "href"=>"https://api.w3.org/users/p3dte6mpoj4sgw888w8kw4w4skwosck",
#       "title"=>"Tab Atkins Jr."
#     },
#     {
#       "href"=>"https://api.w3.org/users/l88ca27n2b4sk00cogosk0skw4s8osc",
#       "title"=>"Chris Wilson"
#     },
#     {
#       "href"=>"https://api.w3.org/users/kjqsxbe6kioko4s88s4wocws848kgw8",
#       "title"=>"David Baron"
#     },
#     {
#       "href"=>"https://api.w3.org/users/t9qq83owlzkck404w0o44so8owc00gg",
#       "title"=>"Rune Lillesveen"
#     },

module W3c
  module Api
    module Models
      class Users < CollectionBase
        attribute :users, User, collection: true

        delegate_enumerable :users
        collection_instance_class User, :users
      end
    end
  end
end
