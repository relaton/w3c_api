# frozen_string_literal: true

require_relative "user"

module W3cApi
  module Models
    class ChairIndex < Lutaml::Hal::Page
      hal_link :chairs, key: "chairs", realize_class: "User", collection: true
    end
  end
end
