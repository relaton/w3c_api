# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in gemspec
gemspec

gem "bundler"
# TEMP: ride lutaml-hal main for the yeptris JSON parse (lutaml-hal#25) —
# the released 0.2.7 expects the Faraday json middleware to have parsed the
# body, which this stack no longer installs. Return to a released pin with
# the next lutaml-hal release.
gem "lutaml-hal", github: "lutaml/lutaml-hal", branch: "main"
gem "rake"
gem "rspec"
gem "rubocop"
gem "rubocop-performance"
gem "rubocop-rake"
gem "rubocop-rspec"
gem "simplecov"
gem "vcr"
