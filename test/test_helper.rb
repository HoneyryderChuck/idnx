# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

if ENV.key?("CI")
  require "simplecov"
  SimpleCov.command_name "#{RUBY_ENGINE}-#{RUBY_PLATFORM}-#{RUBY_VERSION}"
  SimpleCov.coverage_dir "coverage/#{RUBY_ENGINE}-#{RUBY_PLATFORM}-#{RUBY_VERSION}"
end

require "idnx"

require "minitest/autorun"
