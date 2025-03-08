# frozen_string_literal: true

module W3cApi
  module Models
    class JoinEmailIndex < Lutaml::Model::Serializable
      attribute :public, :string
      attribute :member, :string
    end
  end
end
