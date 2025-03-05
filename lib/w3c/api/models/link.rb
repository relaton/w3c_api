# frozen_string_literal: true

require_relative 'base'

# {
#   "href"=>"https://api.w3.org/specifications/png-2/versions/20031110",
#   "title"=>"Recommendation"
# }

module W3c
  module Api
    module Models
      class Link < Lutaml::Model::Serializable
        attribute :href, :string
        attribute :title, :string
      end
    end
  end
end
