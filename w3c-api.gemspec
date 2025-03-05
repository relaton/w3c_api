# frozen_string_literal: true

require_relative "lib/w3c/api/version"

Gem::Specification.new do |spec|
  spec.name = "w3c-api"
  spec.version = W3c::Api::VERSION
  spec.authors = ["W3C API Contributors"]
  spec.email = ["info@example.com"]

  spec.summary = "Ruby client for the W3C API"
  spec.description = "A Ruby wrapper for the W3C web API with a CLI interface"
  spec.homepage = "https://github.com/example/w3c-api"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_dependency "thor", "~> 1.2"
  spec.add_dependency "faraday", "~> 2.0"
  spec.add_dependency "faraday-follow_redirects", "~> 0.3"
  spec.add_dependency "lutaml-model", "~> 0.1"
  spec.add_dependency "terminal-table", "~> 3.0"

  # Development dependencies
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "vcr", "~> 6.0"
  spec.add_development_dependency "simplecov", "~> 0.21"
  spec.add_development_dependency "rubocop", "~> 1.21"
end
