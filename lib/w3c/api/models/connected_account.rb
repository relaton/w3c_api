# frozen_string_literal: true

require 'lutaml/model'

module W3c
  module Api
    module Models
      class ConnectedAccount < Lutaml::Model::Serializable
        attribute :service, :string
        attribute :username, :string
        attribute :url, :string
      end
    end
  end
end
