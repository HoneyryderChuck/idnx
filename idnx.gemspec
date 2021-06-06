# frozen_string_literal: true

require_relative "lib/idnx/version"

Gem::Specification.new do |spec|
  spec.name = "idnx"
  spec.version = Idnx::VERSION
  spec.authors = ["HoneyryderChuck"]
  spec.email = ["cardoso_tiago@hotmail.com"]

  spec.summary = <<-DESC
    Converts International Domain Names into Punycode.
    It uses (via FFI) 'libidn2' for Mac and Linux; for Windows, it uses native APIs.
  DESC
  spec.description = <<-DESC
    Converts International Domain Names into Punycode.
    It uses (via FFI) 'libidn2' for Mac and Linux; for Windows, it uses native APIs.
  DESC
  spec.homepage = "https://github.com/honeyryderchuck/idnx"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

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
