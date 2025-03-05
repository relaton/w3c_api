# frozen_string_literal: true

module W3c
  module Api
    module Models
      class Service < Base
        attribute :type, :string
        attribute :link, :string
        attribute :shortdesc, :string
        attribute :longdesc, :string
        attribute :external, :boolean
        attribute :closed, :boolean
      end
    end
  end
end
