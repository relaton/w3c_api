# frozen_string_literal: true

require_relative "charter"

module W3cApi
  module Models
    class CharterIndex < Lutaml::Hal::Page
      hal_link :charters, key: "charters", realize_class: "Charter",
                          collection: true
    end
  end
end
