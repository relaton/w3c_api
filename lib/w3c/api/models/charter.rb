# frozen_string_literal: true

require_relative 'extension'

module W3c
  module Api
    module Models
      class Charter < Base
        attribute :end, :string # Date-time format
        attribute :title, :string
        attribute :start, :string # Date-time format
        attribute :initial_end, :string # Date-time format
        attribute :uri, :string, pattern: %r{https?://www\.w3\.org.*}
        attribute :cfp_uri, :string, pattern: %r{https://lists\.w3\.org/Archives/Member/w3c-ac-members/.*}
        attribute :extensions, Extension, collection: true
        attribute :required_new_commitments, :boolean
        attribute :patent_policy, :string

        # Parse date strings to Date objects
        def end_date
          Date.parse(self.end) if self.end
        rescue Date::Error
          nil
        end

        def start_date
          Date.parse(start) if start
        rescue Date::Error
          nil
        end

        def initial_end_date
          Date.parse(initial_end) if initial_end
        rescue Date::Error
          nil
        end

        # Check if this charter is active
        def active?
          start_date &&
            (end_date.nil? || end_date >= Date.today) &&
            start_date <= Date.today
        rescue Date::Error
          false
        end

        # Check if this charter has been extended
        def extended?
          !extensions.nil? && !extensions.empty?
        end
      end
    end
  end
end
