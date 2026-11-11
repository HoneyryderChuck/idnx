# frozen_string_literal: true

GC.auto_compact = true if GC.respond_to?(:auto_compact=)

if ENV.key?("CI") && RUBY_VERSION >= "3.2.0"
  require "simplecov"
  SimpleCov.start do
    merging true
    finalize_merge false
  end
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "idnx"

require "minitest/autorun"

if RUBY_VERSION >= "3.4.0"
  Warning.categories.each do |cat|
    Warning[cat] = true
  end
end
