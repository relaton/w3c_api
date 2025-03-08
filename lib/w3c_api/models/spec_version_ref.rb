# frozen_string_literal: true

module W3cApi
  module Models
    class SpecVersionRef < Lutaml::Model::Serializable
      attribute :status, :string
      attribute :rec_track, :boolean
      attribute :editor_draft, :string
      attribute :uri, :string
      attribute :date, :string
      attribute :title, :string
      attribute :shortlink, :string
      attribute :process_rules, :string
    end
  end
end
