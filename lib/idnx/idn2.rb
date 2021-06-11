# frozen_string_literal: true

module Idnx
  module Lib
    extend FFI::Library

    if FFI::Platform.mac?
      ffi_lib ["libidn2", "libidn2.0"]
    else
      ffi_lib ["libidn2.so", "libidn2.so.0"]
    end

    attach_function :idn2_check_version, [:string], :string

    VERSION = idn2_check_version(nil)

    IDN2_OK = 0

    IDN2_NFC_INPUT = 1
    IDN2_TRANSITIONAL = 4
    IDN2_NONTRANSITIONAL = 8

    FLAGS = if Gem::Version.new(VERSION) >= Gem::Version.new("0.14.0")
      IDN2_NFC_INPUT | IDN2_NONTRANSITIONAL
    else
      IDN2_NFC_INPUT
    end

    attach_function :idn2_lookup_ul, [:string, :pointer, :int], :int
    attach_function :idn2_strerror, [:int], :string
    attach_function :idn2_free, [:pointer], :void

    module_function

    def lookup(hostname)
      string_ptr = FFI::MemoryPointer.new(:pointer)
      result = idn2_lookup_ul(hostname, string_ptr, FLAGS)

      if result != IDN2_OK
        result = idn2_lookup_ul(hostname, string_ptr, IDN2_TRANSITIONAL)
      end

      if result != IDN2_OK
        string_ptr.free
        raise Error, "Failed to convert \"#{hostname}\" to ascii; (error: #{idn2_strerror(result)})"
      end

      ptr = string_ptr.read_pointer

      raise Error, "Failed to read \"#{hostname}\" to ascii" if ptr.null?

      ascii = ptr.read_string

      idn2_free(ptr)
      string_ptr.free

      ascii
    end
  end
end
