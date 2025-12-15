# frozen_string_literal: true

require_relative "idnx/version"
require "ffi"

module Idnx
  class Error < StandardError; end

  module_function

  def to_punycode(hostname)
    Lib.lookup(hostname)
  end
end

if FFI::Platform.windows?
  require "idnx/windows"
else
  begin
    require "idnx/idn2"
  rescue LoadError
    # fallback to pure ruby punycode 2003 implementation
    require "idnx/ruby"
    Lib = Ruby
  end
end
