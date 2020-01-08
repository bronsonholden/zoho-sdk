lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "zoho-sdk/version"

Gem::Specification.new do |spec|
  spec.name  = "zoho-sdk"
  spec.version = Zoho::VERSION
  spec.authors = ["Paul Holden"]
  spec.email = ["pholden@stria.com"]

  spec.summary = "A library for interacting with Zoho applications via REST API."
  spec.description = "A library for interacting with Zoho applications via REST API."
  spec.homepage = "https://github.com/paulholden2/zoho-sdk"
  spec.license = "MIT"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/paulholden2/zoho-sdk"
  spec.metadata["changelog_uri"] = "https://github.com/paulholden2/zoho-sdk/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 0.17.1"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "sinatra", "~> 2.0"
  spec.add_development_dependency "webmock", "~> 3.6"
  spec.add_development_dependency "simplecov", "~> 0.17"
  spec.add_development_dependency "yard", "~> 0.9"
end
