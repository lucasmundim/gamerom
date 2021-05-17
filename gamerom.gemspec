# frozen_string_literal: true

require_relative 'lib/gamerom/version'

Gem::Specification.new do |spec|
  spec.name          = 'gamerom'
  spec.version       = Gamerom::VERSION
  spec.authors       = ['Lucas Mundim']
  spec.email         = ['lucas.mundim@gmail.com']

  spec.summary       = 'The Video Game ROM downloader'
  spec.description   = 'A command-line installer for game ROMs from many repositories.'
  spec.homepage      = 'https://github.com/lucasmundim/gamerom'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.0.1')

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'mechanize', '~> 2.8.0'
  spec.add_runtime_dependency 'mechanize-progressbar', '~> 0.2.0'
  spec.add_runtime_dependency 'nokogiri', '~> 1.11.3'
  spec.add_runtime_dependency 'progressbar', '~> 0.9.0'
  spec.add_runtime_dependency 'rest-client', '~> 2.1.0'
  spec.add_runtime_dependency 'thor', '~> 1.1.0'

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
