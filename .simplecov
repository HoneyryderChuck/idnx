# frozen_string_literal: true

SimpleCov.start do
  command_name "Spec"
  add_filter "/.bundle/"
  add_filter "/vendor/"
  add_filter "/test/"
  coverage_dir "coverage"
end
