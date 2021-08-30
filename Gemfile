# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in idnx.gemspec
gemspec

gem "minitest", "~> 5.0"
gem "pry"
gem "pry-byebug" unless Gem.win_platform? || RUBY_ENGINE != "ruby"
gem "rake", "~> 13.0"
gem "standard"

platform :jruby do
  gem "jruby-win32ole" if Gem.win_platform?
end
