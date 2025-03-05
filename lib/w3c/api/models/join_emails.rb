# frozen_string_literal: true

require 'lutaml/model'

module W3c
  module Api
    module Models
      class JoinEmails < Lutaml::Model::Serializable
        attribute :public, :string
        attribute :member, :string
      end
    end
  end
end
