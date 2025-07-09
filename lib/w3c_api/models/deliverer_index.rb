# frozen_string_literal: true

require_relative "group"

module W3cApi
  module Models
    # Collection of deliverers (working groups)
    class DelivererIndex < Lutaml::Hal::Page
      hal_link :deliverers, key: "deliverers", realize_class: "Group",
                            collection: true
    end
  end
end
