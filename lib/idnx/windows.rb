require 'win32ole'

module Idnx
  module Lib
    extend FFI::Library

    ffi_lib "Normaliz.dll"
    ffi_lib "kernel32.dll"

    IDN_MAX_LENGTH = 255
    MB_ERR_INVALID_CHARS = 0x00000008

    ERROR_INSUFFICIENT_BUFFER = 0x7A
    ERROR_INVALID_FLAGS = 0x3EC
    ERROR_INVALID_NAME = 0x7B
    ERROR_INVALID_PARAMETER = 0x57
    ERROR_NO_UNICODE_TRANSLATION = 0x459

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
    attach_function :IdnToAscii, [:uint, :pointer, :int, :pointer, :int], :int
    attach_function :MultiByteToWideChar, [:uint, :uint, :string, :int, :pointer, :int], :int
    attach_function :WideCharToMultiByte, [:uint, :uint, :pointer, :int, :pointer, :int, :pointer, :pointer], :int

    module_function

    def lookup(hostname)
      # turn to wchar
      wchar_len = MultiByteToWideChar(WIN32OLE::CP_UTF8, MB_ERR_INVALID_CHARS, hostname, -1, nil, 0)
      raise Error, "Failed to convert \"#{hostname}\" to wchar" if wchar_len.zero?
      wchar_ptr = FFI::MemoryPointer.new(:wchar_t, wchar_len)
      wchar_len = MultiByteToWideChar(WIN32OLE::CP_UTF8, 0, hostname, -1, wchar_ptr, wchar_len)
      raise Error, "Failed to convert \"#{hostname}\" to wchar" if wchar_len.zero?

      # translate to punycode
      punycode = FFI::MemoryPointer.new(:wchar_t, IDN_MAX_LENGTH)
      punycode_len = IdnToAscii(0, wchar_ptr, -1, punycode, IDN_MAX_LENGTH)
      wchar_ptr.free

      if punycode_len == 0
        last_error = FFI::LastError.error

        # operation completed successfully, hostname is not an IDN
        # return hostname if last_error == 0

        message = case last_error
        when ERROR_INSUFFICIENT_BUFFER
          "The supplied buffer size was not large enough, or it was incorrectly set to NULL"
        when ERROR_INVALID_FLAGS
          "The values supplied for flags were not valid"
        when ERROR_INVALID_NAME
          "An invalid name was supplied to the function"
        when ERROR_INVALID_PARAMETER
          "Any of the parameter values was invalid"
        when ERROR_NO_UNICODE_TRANSLATION
          "An invalid Unicode was found in a string"
        else
          "Failed to convert \"#{hostname}\"; (error: #{last_error})" \
            "\n\nhttps://docs.microsoft.com/en-us/windows/win32/debug/system-error-codes#system-error-codes-1"
        end
        punycode.free
        raise Error, message
      end

      # turn to unicode
      unicode_len = WideCharToMultiByte(WIN32OLE::CP_UTF8, 0, punycode, -1, nil, 0, nil, nil)
      raise Error, "Failed to convert \"#{hostname}\" to utf8" if unicode_len.zero?
      utf8_ptr = FFI::MemoryPointer.new(:char, unicode_len)
      unicode_len = WideCharToMultiByte(WIN32OLE::CP_UTF8, 0, punycode, -1, utf8_ptr, unicode_len, nil, nil)
      raise Error, "Failed to convert \"#{hostname}\" to utf8" if unicode_len.zero? 
      unicode = utf8_ptr.read_string(utf8_ptr.size)
      unicode.strip! # remove null-byte
    end
  end
end