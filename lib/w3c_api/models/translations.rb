# frozen_string_literal: true

require 'lutaml/model'
require_relative 'translation'
require_relative 'delegate_enumerable'
require_relative 'collection_base'

# {
#   "page"=>1,
#   "limit"=>100,
#   "pages"=>7,
#   "total"=>631,
#   "_links"=>{
#     "translations"=>[
#       {
#         "href"=>"https://api.w3.org/translations/2",
#         "title"=>"Vidéo : introduction à l’accessibilité web et aux standards du W3C",
#         "language"=>"fr"
#       },
#       {
#         "href"=>"https://api.w3.org/translations/3",
#         "title"=>"Vídeo de Introducción a la Accesibilidad Web y Estándares del W3C",
#         "language"=>"es"
#       },
#       {
#         "href"=>"https://api.w3.org/translations/4",
#         "title"=>"Video-introductie over Web-toegankelijkheid en W3C-standaarden",
#         "language"=>"nl"
#       },

module W3cApi
    module Models
      class Translations < CollectionBase
        attribute :translations, Translation, collection: true

        delegate_enumerable :translations
        collection_instance_class Translation, :translations
      end
    end
end
