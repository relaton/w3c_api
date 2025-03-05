# frozen_string_literal: true

require 'lutaml/model'
require_relative 'translation'
require_relative 'delegate_enumerable'

module W3c
  module Api
    module Models
      class Translations < Lutaml::Model::Serializable
        extend DelegateEnumerable

        attribute :translations, Translation, collection: true

        delegate_enumerable :translations
      end
    end
  end
end
