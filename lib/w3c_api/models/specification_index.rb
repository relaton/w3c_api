# frozen_string_literal: true

require_relative "specification"

module W3cApi
  module Models
    # SpecificationIndex class that models `/specifications`
    class SpecificationIndex < Lutaml::Hal::Page
      hal_link :specifications, key: "specifications",
                                realize_class: "Specification", collection: true
    end
  end
end
