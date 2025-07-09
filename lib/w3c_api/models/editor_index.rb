# frozen_string_literal: true

require_relative "user"

module W3cApi
  module Models
    # Collection of editors
    class EditorIndex < Lutaml::Hal::Page
      hal_link :editors, key: "editors", realize_class: "User", collection: true
    end
  end
end
