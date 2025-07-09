# frozen_string_literal: true

require "thor"
require_relative "commands/specification"
require_relative "commands/specification_version"
require_relative "commands/group"
require_relative "commands/user"
require_relative "commands/translation"
require_relative "commands/ecosystem"
require_relative "commands/series"
require_relative "commands/affiliation"
require_relative "commands/participation"

module W3cApi
  # Main CLI class that registers all subcommands
  class Cli < Thor
    # Register subcommands
    desc "specification SUBCOMMAND ...ARGS", "Work with W3C specifications"
    subcommand "specification", Commands::Specification

    desc "specification_version SUBCOMMAND ...ARGS",
         "Work with W3C specification versions"
    subcommand "specification_version", Commands::SpecificationVersion

    desc "group SUBCOMMAND ...ARGS", "Work with W3C groups"
    subcommand "group", Commands::Group

    desc "user SUBCOMMAND ...ARGS", "Work with W3C users"
    subcommand "user", Commands::User

    desc "translation SUBCOMMAND ...ARGS", "Work with W3C translations"
    subcommand "translation", Commands::Translation

    desc "ecosystem SUBCOMMAND ...ARGS", "Work with W3C ecosystems"
    subcommand "ecosystem", Commands::Ecosystem

    desc "series SUBCOMMAND ...ARGS", "Work with W3C specification series"
    subcommand "series", Commands::Series

    desc "affiliation SUBCOMMAND ...ARGS", "Work with W3C affiliations"
    subcommand "affiliation", Commands::Affiliation

    desc "participation SUBCOMMAND ...ARGS", "Work with W3C participations"
    subcommand "participation", Commands::Participation
  end
end
