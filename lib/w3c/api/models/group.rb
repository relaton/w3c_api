# frozen_string_literal: true

require_relative 'join_emails'

module W3c
  module Api
    module Models
      class Group < Base
        attribute :id, :integer
        attribute :name, :string
        attribute :type, :string
        attribute :description, :string
        attribute :shortname, :string
        attribute :shortlink, :string
        attribute :discr, :string
        attribute :created, :string # Date-time format
        attribute :start_date, :string # Date-time format
        attribute :end_date, :string # Date-time format
        attribute :is_closed, :boolean
        attribute :patent_policy, :string
        attribute :charter_closed, :boolean
        attribute :join_emails, JoinEmails

        # Parse date strings to Date objects
        def created_date
          Date.parse(created) if created
        rescue Date::Error
          nil
        end

        def start_date_parsed
          Date.parse(start_date) if start_date
        rescue Date::Error
          nil
        end

        def end_date_parsed
          Date.parse(end_date) if end_date
        rescue Date::Error
          nil
        end

        # Check if this group is active
        def active?
          !is_closed && (!end_date || Date.parse(end_date) > Date.today)
        rescue Date::Error
          !is_closed
        end
      end
    end
  end
end
