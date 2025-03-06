# frozen_string_literal: true

require 'lutaml/model'

module W3cApi
    module Models
      class JoinEmails < Lutaml::Model::Serializable
        attribute :public, :string
        attribute :member, :string
      end
    end
end
