# frozen_string_literal: true

require 'lutaml/model'
require_relative 'group'
require_relative 'delegate_enumerable'
require_relative 'collection_base'

# Response body:
# {
#   "page": 1,
#   "limit": 100,
#   "pages": 3,
#   "total": 257,
#   "_links": {
#     "groups": [
#       {
#         "href": "https://api.w3.org/groups/tf/ab-liaisons-to-bod",
#         "title": "AB Liaisons to the Board of Directors"
#       },
#       {
#         "href": "https://api.w3.org/groups/cg/a11yedge",
#         "title": "Accessibility at the Edge Community Group"
#       },
#       {
#         "href": "https://api.w3.org/groups/tf/wcag-act",
#         "title": "Accessibility Conformance Testing (ACT) Task Force"
#       },

module W3cApi
  module Models
    class Groups < CollectionBase
      attribute :groups, Group, collection: true

      delegate_enumerable :groups
      collection_instance_class Group, :groups
    end
  end
end
