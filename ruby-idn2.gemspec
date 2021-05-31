# frozen_string_literal: true

require_relative "lib/idn2/version"

Gem::Specification.new do |spec|
  spec.name = "idn2"
  spec.version = Idn2::VERSION
  spec.authors = ["HoneyryderChuck"]
  spec.email = ["cardoso_tiago@hotmail.com"]

  spec.summary = "Ruby bindings for libidn2."
  spec.description = "Ruby bindings for libidn2."
  spec.homepage = "https://gitlab.com/honeyryderchuck/ruby-idn2"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.1.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage + "/-/blob/master/CHANGELOG.md"

  spec.files = Dir["LICENSE.txt", "README.md", "lib/**/*.rb"]
  spec.extra_rdoc_files = Dir["LICENSE.txt", "README.md"]

  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "ffi", ["~> 1.12"]

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
