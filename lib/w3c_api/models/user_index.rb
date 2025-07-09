# frozen_string_literal: true

require_relative "user"

module W3cApi
  module Models
    class UserIndex < Lutaml::Hal::Page
      hal_link :users, key: "users", realize_class: "User", collection: true
    end
  end
end
