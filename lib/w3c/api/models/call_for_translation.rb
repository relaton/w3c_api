# frozen_string_literal: true

require_relative 'spec_version_ref'

module W3c
  module Api
    module Models
      class CallForTranslation < Base
        attribute :uri, :string
        attribute :title, :string
        attribute :spec_version, SpecVersionRef
        attribute :comments, :string
      end
    end
  end
end
