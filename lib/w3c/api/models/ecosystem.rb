# frozen_string_literal: true

module W3c
  module Api
    module Models
      class Ecosystem < Base
        attribute :name, :string
        attribute :shortname, :string, pattern: /[a-z][a-z0-9-]{0,30}[a-z0-9]/
      end
    end
  end
end
