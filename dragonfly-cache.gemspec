# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dragonfly/cache/version'

Gem::Specification.new do |spec|
  spec.name          = 'dragonfly-cache'
  spec.version       = Dragonfly::Cache::VERSION
  spec.licenses      = ['Apache-2.0']
  spec.authors       = ['Gaël-Ian Havard']
  spec.email         = ['gael-ian@notus.sh']

  spec.summary       = 'Cache adapter for Dragonfly'
  spec.description   = 'Allow Dragonfly to keep a cache of jobs results'
  spec.homepage      = 'https://github.com/notus-sh/dragonfly-cache'

  raise 'RubyGems 2.0 or newer is required.' unless spec.respond_to?(:metadata)

  spec.metadata = {
    'allowed_push_host' => 'https://rubygems.org',
    'rubygems_mfa_required' => 'true',

    'bug_tracker_uri' => 'https://github.com/notus-sh/dragonfly-cache/issues',
    'changelog_uri' => 'https://github.com/notus-sh/dragonfly-cache/blob/master/CHANGELOG.md',
    'homepage_uri' => 'https://github.com/notus-sh/dragonfly-cache',
    'source_code_uri' => 'https://github.com/notus-sh/dragonfly-cache',
    'funding_uri' => 'https://opencollective.com/notus-sh'
  }

  spec.require_paths = ['lib']

  excluded_dirs = %r{^(.github|spec)/}
  excluded_files = %w[.gitignore .rspec .rubocop.yml Gemfile Gemfile.lock Rakefile]
  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(excluded_dirs) || excluded_files.include?(f)
  end

  spec.required_ruby_version = '>= 2.6'

  spec.add_dependency 'dragonfly'
  spec.add_dependency 'i18n'

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.12.0'

  spec.post_install_message = <<~POST_INSTALL_MESSAGE
    Don't forget to configure Dragonfly::Cache:

        Dragonfly.app.configure do
          plugin :dragonfly_cache,
            server_root: Rails.application.root.join('public'),
            url_format:  '/media-cache/:sha/:name'
        end

  POST_INSTALL_MESSAGE
end
