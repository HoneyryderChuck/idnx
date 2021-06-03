# frozen_string_literal: true

require_relative "idn2/version"

require "ffi"

module Idn2
  Error = Class.new(StandardError)

  module Lib
    extend FFI::Library

    if FFI::Platform.windows?
      ffi_lib "winnls"

      IDN_MAX_LENGTH = 255

      # int IdnToAscii(
      #   DWORD   dwFlags,
      #   LPCWSTR lpUnicodeCharStr,
      #   int     cchUnicodeChar,
      #   LPWSTR  lpASCIICharStr,
      #   int     cchASCIIChar
      # );

      attach_function :IdnToAscii, [:int, :string, :int, :pointer, :int], :integer
      attach_function :GetLastError, [], :integer

      # attach_function :curl_win32_idn_to_ascii, [:string,  :int], :int

      def self.lookup(hostname)
        read_pointer = FFI::Pointer.new(:char, 255)
        result = IdnToAscii(0, hostname, -1, read_pointer, IDN_MAX_LENGTH)

        if result == 0
          read_pointer.free
          last_error = GetLastError
          raise Error, "Failed to convert \"#{hostname}\" to ascii; (error: #{last_error})"
        end

        read_pointer.read_string(result)
      end
    else

      ffi_lib "libidn2"

      attach_function :idn2_check_version, [], :int

      VERSION = idn2_check_version

      IDN2_OK = 0

      IDN2_NFC_INPUT = 1
      IDN2_TRANSITIONAL = 4
      IDN2_NONTRANSITIONAL = 8

      FLAGS = if VERSION >= 0x00140000
        IDN2_NFC_INPUT | IDN2_NONTRANSITIONAL
      else
        IDN2_NFC_INPUT
      end

      attach_function :idn2_lookup_ul, [:string, :pointer, :int], :int
      attach_function :idn2_strerror, [:int], :string
      attach_function :idn2_free, [:pointer], :void

      def self.lookup(hostname)
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

  module_function

  def convert(hostname)
    Lib.lookup(hostname)
  end
end
