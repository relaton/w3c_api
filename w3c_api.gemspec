# frozen_string_literal: true

require_relative 'lib/w3c_api/version'

Gem::Specification.new do |spec|
  spec.name = 'w3c_api'
  spec.version = W3cApi::VERSION
  spec.authors = ['Ribose Inc.']
  spec.email = ['open.source@ribose.com']

  spec.summary = 'Ruby client for the W3C API'
  spec.description = 'A Ruby wrapper for the W3C web API with a CLI interface'
  spec.homepage = 'https://github.com/relaton/w3c-api'
  spec.license = 'BSD-2-Clause'

  # spec.extra_rdoc_files = %w[docs/README.adoc LICENSE]
  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__,
                                             err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor
                          Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.7.0'

  spec.add_dependency 'faraday'
  spec.add_dependency 'faraday-follow_redirects'
  spec.add_dependency 'lutaml-hal'
  spec.add_dependency 'lutaml-model'
  spec.add_dependency 'rainbow'
  spec.add_dependency 'thor'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = spec.homepage
end
