# frozen_string_literal: true

require_relative "idnx/version"
require "ffi"

module Idnx
  Error = Class.new(StandardError)

  module_function

  def convert(hostname)
    Lib.lookup(hostname)
  end
end

if FFI::Platform.windows?
  require "idnx/windows"
else
  require "idnx/idn2"
end
