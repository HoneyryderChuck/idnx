# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "idnx"

require "minitest/autorun"

if RUBY_VERSION >= "3.4.0"
  Warning.categories.each do |cat|
    Warning[cat] = true
  end
end
