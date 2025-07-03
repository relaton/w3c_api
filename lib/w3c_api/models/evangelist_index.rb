# frozen_string_literal: true

require_relative "user"

module W3cApi
  module Models
    class EvangelistIndex < Lutaml::Hal::Page
      hal_link :evangelists, key: "evangelists", realize_class: "User",
                             collection: true
    end
  end
end
