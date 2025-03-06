# frozen_string_literal: true

require 'lutaml/model'

module W3cApi
    module Models
      class Extension < Lutaml::Model::Serializable
        attribute :end, :string
        attribute :announcement, :string
      end
    end
end
