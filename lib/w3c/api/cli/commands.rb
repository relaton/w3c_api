# frozen_string_literal: true

require 'thor'
require_relative 'specification'
require_relative 'group'
require_relative 'user'
require_relative 'translation'
require_relative 'ecosystem'
require_relative 'service'

module W3c
  module Api
    module Cli
      # Main CLI class that registers all subcommands
      class Commands < Thor
        # Register subcommands
        desc 'specification SUBCOMMAND ...ARGS', 'Work with W3C specifications'
        subcommand 'specification', Specification

        desc 'group SUBCOMMAND ...ARGS', 'Work with W3C groups'
        subcommand 'group', Group

        desc 'user SUBCOMMAND ...ARGS', 'Work with W3C users'
        subcommand 'user', User

        desc 'translation SUBCOMMAND ...ARGS', 'Work with W3C translations'
        subcommand 'translation', Translation

        desc 'ecosystem SUBCOMMAND ...ARGS', 'Work with W3C ecosystems'
        subcommand 'ecosystem', Ecosystem

        desc 'service SUBCOMMAND ...ARGS', 'Work with W3C services'
        subcommand 'service', Service
      end
    end
  end
end
