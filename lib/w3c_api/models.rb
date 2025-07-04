# frozen_string_literal: true

module W3cApi
  module Models
    # Use autoload to defer class loading until first access
    # This eliminates the class loading order dependency that caused
    # inconsistent type names in HAL output

    autoload :Account, 'w3c_api/models/account'
    autoload :Affiliation, 'w3c_api/models/affiliation'
    autoload :AffiliationIndex, 'w3c_api/models/affiliation_index'
    autoload :CallForTranslation, 'w3c_api/models/call_for_translation'
    autoload :ChairIndex, 'w3c_api/models/chair_index'
    autoload :Charter, 'w3c_api/models/charter'
    autoload :CharterIndex, 'w3c_api/models/charter_index'
    autoload :ConnectedAccount, 'w3c_api/models/connected_account'
    autoload :DelivererIndex, 'w3c_api/models/deliverer_index'
    autoload :Ecosystem, 'w3c_api/models/ecosystem'
    autoload :EcosystemIndex, 'w3c_api/models/ecosystem_index'
    autoload :EditorIndex, 'w3c_api/models/editor_index'
    autoload :EvangelistIndex, 'w3c_api/models/evangelist_index'
    autoload :Extension, 'w3c_api/models/extension'
    autoload :Group, 'w3c_api/models/group'
    autoload :GroupIndex, 'w3c_api/models/group_index'
    autoload :Groups, 'w3c_api/models/groups'
    autoload :JoinEmails, 'w3c_api/models/join_emails'
    autoload :ParticipantIndex, 'w3c_api/models/participant_index'
    autoload :Participation, 'w3c_api/models/participation'
    autoload :ParticipationIndex, 'w3c_api/models/participation_index'
    autoload :Photo, 'w3c_api/models/photo'
    autoload :Serie, 'w3c_api/models/serie'
    autoload :SerieIndex, 'w3c_api/models/serie_index'
    autoload :SpecVersion, 'w3c_api/models/spec_version'
    autoload :SpecVersionIndex, 'w3c_api/models/spec_version_index'
    autoload :SpecVersionPredecessorIndex, 'w3c_api/models/spec_version_predecessor_index'
    autoload :SpecVersionSuccessorIndex, 'w3c_api/models/spec_version_successor_index'
    autoload :SpecVersionRef, 'w3c_api/models/spec_version_ref'
    autoload :Specification, 'w3c_api/models/specification'
    autoload :SpecificationIndex, 'w3c_api/models/specification_index'
    autoload :TeamContactIndex, 'w3c_api/models/team_contact_index'
    autoload :Testimonial, 'w3c_api/models/testimonial'
    autoload :Translation, 'w3c_api/models/translation'
    autoload :TranslationIndex, 'w3c_api/models/translation_index'
    autoload :User, 'w3c_api/models/user'
    autoload :UserIndex, 'w3c_api/models/user_index'
  end
end
