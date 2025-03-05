# frozen_string_literal: true

require_relative 'call_for_translation_ref'

module W3c
  module Api
    module Models
      class Translation < Base
        attribute :uri, :string
        attribute :title, :string
        attribute :language, :string
        attribute :published, :string # Date-time format
        attribute :updated, :string # Date-time format
        attribute :authorized, :boolean
        attribute :lto_name, :string
        attribute :call_for_translation, CallForTranslationRef
        attribute :comments, :string

        # Parse date strings to Date objects
        def published_date
          Date.parse(published) if published
        rescue Date::Error
          nil
        end

        def updated_date
          Date.parse(updated) if updated
        rescue Date::Error
          nil
        end

        # Get the call for translation as a CallForTranslation object
        def call_for_translation_object
          return nil unless call_for_translation

          Models::CallForTranslation.new(call_for_translation)
        end

        # Get the specification version associated with this translation
        def specification_version(client = nil)
          return nil unless call_for_translation&.spec_version

          call_for_translation.spec_version
        end
      end
    end
  end
end
