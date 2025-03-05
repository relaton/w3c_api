# frozen_string_literal: true

module W3c
  module Api
    module Models
      class Specification < Base
        attribute :shortlink, :string
        attribute :description, :string
        attribute :title, :string
        attribute :shortname, :string
        attribute :editor_draft, :string
        attribute :series_version, :string

        # Return versions of this specification
        def versions(client = nil)
          return nil unless client && shortname

          client.specification_versions(shortname)
        end
      end
    end
  end
end
