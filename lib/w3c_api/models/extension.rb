# frozen_string_literal: true

module W3cApi
  module Models
    class Extension < Lutaml::Model::Serializable
      attribute :end, :date_time
      attribute :announcement_uri, :string
    end
  end
end
