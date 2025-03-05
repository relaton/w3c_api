# frozen_string_literal: true

require 'lutaml/model'

module W3c
  module Api
    module Models
      class Extension < Lutaml::Model::Serializable
        attribute :end, :string
        attribute :announcement, :string
      end
    end
  end
end
