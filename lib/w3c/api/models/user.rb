# frozen_string_literal: true

require_relative 'connected_account'

module W3c
  module Api
    module Models
      class User < Base
        attribute :id, :integer
        attribute :name, :string
        attribute :email, :string
        attribute :given, :string, pattern: %r{[^<>":=+/\\]*}
        attribute :family, :string, pattern: %r{[^<>":=+/\\]*}
        attribute :work_title, :string, pattern: /[^<>":=+\\]*/
        attribute :biography, :string
        attribute :phone, :string, pattern: /\+([1-9][0-9]{0,2}\.?)([0-9]+\.?)*[0-9]+/
        attribute :country_code, :string
        attribute :country_division, :string
        attribute :city, :string
        attribute :connected_accounts, ConnectedAccount, collection: true

        # Get full name from given and family name
        def full_name
          [given, family].compact.join(' ')
        end
      end
    end
  end
end
