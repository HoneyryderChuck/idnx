# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in idnx.gemspec
gemspec

if RUBY_VERSION >= "3.0.0" && RUBY_ENGINE == "ruby"
  gem "debug"
  gem "rbs"
  gem "steep"
end

gem "minitest", "~> 5.0"
gem "rake", "~> 13.0"
gem "rubocop"
gem "rubocop-performance"
gem "rubocop-thread_safety"
gem "simplecov"

platform :jruby do
  gem "jruby-win32ole" if Gem.win_platform?
end
