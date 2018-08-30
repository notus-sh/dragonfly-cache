
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "dragonfly/cache/version"

Gem::Specification.new do |spec|
  spec.name          = "dragonfly-cache"
  spec.version       = Dragonfly::Cache::VERSION
  spec.authors       = ["Gaël-Ian Havard"]
  spec.email         = ["gael-ian@notus.sh"]

  spec.summary       = %q{Cache adapter for Dragonfly}
  spec.description   = %q{Allow Dragonfly to keep a cache of jobs results}
  spec.homepage      = "https://github.com/notus-sh/dragonfly-cache"

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required.'
  end

  spec.require_paths = ["lib"]
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
end
