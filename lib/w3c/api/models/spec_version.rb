# frozen_string_literal: true

module W3c
  module Api
    module Models
      class SpecVersion < Base
        attribute :status, :string
        attribute :rec_track, :boolean
        attribute :editor_draft, :string
        attribute :uri, :string, pattern: %r{https://www\.w3\.org/.*}
        attribute :date, :string # Date-time format
        attribute :last_call_feedback_due, :string # Date-time format
        attribute :pr_reviews_date, :string # Date-time format
        attribute :implementation_feedback_due, :string # Date-time format
        attribute :per_reviews_due, :string # Date-time format
        attribute :informative, :boolean
        attribute :title, :string
        attribute :shortlink, :string, pattern: %r{https://www\.w3\.org/.*}
        attribute :translation, :string
        attribute :errata, :string
        attribute :process_rules, :string

        # Parse date strings to Date objects
        def publication_date
          Date.parse(date) if date
        rescue Date::Error
          nil
        end

        def last_call_feedback_due_date
          Date.parse(last_call_feedback_due) if last_call_feedback_due
        rescue Date::Error
          nil
        end

        def pr_reviews_date_parsed
          Date.parse(pr_reviews_date) if pr_reviews_date
        rescue Date::Error
          nil
        end

        def implementation_feedback_due_date
          Date.parse(implementation_feedback_due) if implementation_feedback_due
        rescue Date::Error
          nil
        end

        def per_reviews_due_date
          Date.parse(per_reviews_due) if per_reviews_due
        rescue Date::Error
          nil
        end

        # Check if this spec version is a Recommendation
        def recommendation?
          status == 'REC'
        end

        # Check if this spec version is a Working Draft
        def working_draft?
          status == 'WD'
        end

        # Check if this spec version is a Candidate Recommendation
        def candidate_recommendation?
          status == 'CR'
        end
      end
    end
  end
end
