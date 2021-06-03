# frozen_string_literal: true

require_relative "idn2/version"

require "ffi"

module Idn2
  Error = Class.new(StandardError)

  module Lib
    extend FFI::Library

    if FFI::Platform.windows?
      require 'win32ole'

      ffi_lib "Normaliz.dll"
      ffi_lib "kernel32.dll"

      IDN_MAX_LENGTH = 255
      MB_ERR_INVALID_CHARS = 0x00000008

      # int IdnToAscii(
      #   DWORD   dwFlags,
      #   LPCWSTR lpUnicodeCharStr,
      #   int     cchUnicodeChar,
      #   LPWSTR  lpASCIICharStr,
      #   int     cchASCIIChar
      # );
      #
      # int MultiByteToWideChar(
      #   UINT                              CodePage,
      #   DWORD                             dwFlags,
      #   _In_NLS_string_(cbMultiByte)LPCCH lpMultiByteStr,
      #   int                               cbMultiByte,
      #   LPWSTR                            lpWideCharStr,
      #   int                               cchWideChar
      # );
      #
      # int WideCharToMultiByte(
      #   UINT                               CodePage,
      #   DWORD                              dwFlags,
      #   _In_NLS_string_(cchWideChar)LPCWCH lpWideCharStr,
      #   int                                cchWideChar,
      #   LPSTR                              lpMultiByteStr,
      #   int                                cbMultiByte,
      #   LPCCH                              lpDefaultChar,
      #   LPBOOL                             lpUsedDefaultChar
      # );
      attach_function :IdnToAscii, [:uint, :string, :int, :pointer, :int], :int
      attach_function :GetLastError, [], :int
      attach_function :MultiByteToWideChar, [:uint, :uint, :string, :int, :pointer, :int], :int
      attach_function :WideCharToMultiByte, [:uint, :uint, :string, :int, :pointer, :int, :pointer, :pointer], :int

      def self.lookup(hostname)
        puts "1: #{hostname.inspect}"
        wchar_hostname = utf8_to_wchar(hostname)

        puts "2: #{wchar_hostname.inspect}"
        raise Error, "Failed to convert \"#{hostname}\" to wchar" unless wchar_hostname

        string_ptr = FFI::MemoryPointer.new(:wchar_t, IDN_MAX_LENGTH)
        len = IdnToAscii(0, wchar_hostname, -1, string_ptr, IDN_MAX_LENGTH)

        if len == 0
          last_error = GetLastError()
          raise Error, "Failed to convert \"#{hostname}\" to ascii; (error: #{last_error})"
        end

        punycode = string_ptr.read_string(len * 2)
        puts "3: #{punycode.inspect}"
        string_ptr.free

        ascii = wchar_to_utf8(punycode)

        puts "4: #{ascii.inspect}"
        raise Error, "Failed to convert \"#{ascii}\" to utf8" unless ascii

        ascii
      end

      def self.utf8_to_wchar(string)
        len = MultiByteToWideChar(WIN32OLE::CP_UTF8, MB_ERR_INVALID_CHARS, string, -1, nil, 0)

        return if len.zero?

        wchar_ptr = FFI::MemoryPointer.new(:wchar_t, len)

        len = MultiByteToWideChar(WIN32OLE::CP_UTF8, 0, string, -1, wchar_ptr, len)
         
        wchar_string = if len.zero?
          nil
        else
          wchar_ptr.read_string(len * 2)
        end
        puts "len: #{len}, str len: #{wchar_string.size}"


        wchar_ptr.free

        wchar_string.gsub!("\x00", "")
      end

      def self.wchar_to_utf8(string)
        len = WideCharToMultiByte(WIN32OLE::CP_UTF8, 0, string, -1, nil, 0, nil, nil)

        return if len.zero?

        utf8_ptr = FFI::MemoryPointer.new(:char, len)

        len = WideCharToMultiByte(WIN32OLE::CP_UTF8, 0, string, -1, utf8_ptr, len, nil, nil)
         
        utf8_string = if len.zero?
          nil
        else
          utf8_ptr.read_string
        end


        utf8_ptr.free

        utf8_string
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
