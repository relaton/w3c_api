# frozen_string_literal: true

module W3cApi
  module Models
    # Use autoload to defer class loading until first access
    # This eliminates the class loading order dependency that caused
    # inconsistent type names in HAL output

    autoload :Account, File.expand_path("models/account", __dir__)
    autoload :Affiliation, File.expand_path("models/affiliation", __dir__)
    autoload :AffiliationIndex,
             File.expand_path("models/affiliation_index", __dir__)
    autoload :CallForTranslation,
             File.expand_path("models/call_for_translation", __dir__)
    autoload :ChairIndex, File.expand_path("models/chair_index", __dir__)
    autoload :Charter, File.expand_path("models/charter", __dir__)
    autoload :CharterIndex, File.expand_path("models/charter_index", __dir__)
    autoload :ConnectedAccount,
             File.expand_path("models/connected_account", __dir__)
    autoload :DelivererIndex,
             File.expand_path("models/deliverer_index", __dir__)
    autoload :Ecosystem, File.expand_path("models/ecosystem", __dir__)
    autoload :EcosystemIndex,
             File.expand_path("models/ecosystem_index", __dir__)
    autoload :EditorIndex, File.expand_path("models/editor_index", __dir__)
    autoload :EvangelistIndex,
             File.expand_path("models/evangelist_index", __dir__)
    autoload :Extension, File.expand_path("models/extension", __dir__)
    autoload :Group, File.expand_path("models/group", __dir__)
    autoload :GroupIndex, File.expand_path("models/group_index", __dir__)
    autoload :Groups, File.expand_path("models/groups", __dir__)
    autoload :JoinEmailIndex, File.expand_path("models/join_emails", __dir__)
    autoload :ParticipantIndex,
             File.expand_path("models/participant_index", __dir__)
    autoload :Participation, File.expand_path("models/participation", __dir__)
    autoload :ParticipationIndex,
             File.expand_path("models/participation_index", __dir__)
    autoload :Photo, File.expand_path("models/photo", __dir__)
    autoload :Serie, File.expand_path("models/serie", __dir__)
    autoload :SerieIndex, File.expand_path("models/serie_index", __dir__)
    autoload :SpecVersion, File.expand_path("models/spec_version", __dir__)
    autoload :SpecVersionIndex,
             File.expand_path("models/spec_version_index", __dir__)
    autoload :SpecVersionPredecessorIndex,
             File.expand_path("models/spec_version_predecessor_index", __dir__)
    autoload :SpecVersionSuccessorIndex,
             File.expand_path("models/spec_version_successor_index", __dir__)
    autoload :SpecVersionRef,
             File.expand_path("models/spec_version_ref", __dir__)
    autoload :Specification, File.expand_path("models/specification", __dir__)
    autoload :SpecificationIndex,
             File.expand_path("models/specification_index", __dir__)
    autoload :TeamContactIndex,
             File.expand_path("models/team_contact_index", __dir__)
    autoload :Testimonial, File.expand_path("models/testimonial", __dir__)
    autoload :Translation, File.expand_path("models/translation", __dir__)
    autoload :TranslationIndex,
             File.expand_path("models/translation_index", __dir__)
    autoload :User, File.expand_path("models/user", __dir__)
    autoload :UserIndex, File.expand_path("models/user_index", __dir__)
  end
end
