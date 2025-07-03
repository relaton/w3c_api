# frozen_string_literal: true

require_relative 'specification_index'

module W3cApi
  module Models
    # Manual GroupLinkSet class to fix collection issue
    class GroupLinkSet < Lutaml::Hal::LinkSet
      # Define the specifications attribute with collection: true
      # This is needed because the Group model's specifications link
      # realizes to a SpecificationIndex which contains a collection
      attribute :specifications, SpecificationIndexLink, collection: true

      key_value do
        map 'specifications', to: :specifications
      end
    end

    # Define the link class for SpecificationIndex
    class SpecificationIndexLink < Lutaml::Hal::Link
      attribute :type, :string, default: 'SpecificationIndex'
    end
  end
end
