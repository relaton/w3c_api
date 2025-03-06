# frozen_string_literal: true

require 'lutaml/model'
require_relative 'spec_version_ref'

module W3cApi
    module Models
      class CallForTranslationRef < Lutaml::Model::Serializable
        attribute :uri, :string
        attribute :title, :string
        attribute :comments, :string
        attribute :spec_version, SpecVersionRef
      end
    end
end
