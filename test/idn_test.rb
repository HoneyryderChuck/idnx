# frozen_string_literal: true

require "test_helper"

class IdnTest < Minitest::Test
  def test_convert
    idnname = Idnx.convert("bücher.ch")

    assert idnname == "xn--bcher-kva.ch", "waiting for idn version, instead got '#{idnname}'"
  end

  def test_convert_ascii
    idnname = Idnx.convert("google.ch")

    assert idnname == "google.ch", "waiting for 'google.ch', instead got '#{idnname}'"
  end

  def test_convert_error
    error_pattern = FFI::Platform.windows? ? /invalid name was supplied/ : /domain name longer than/
    error = assert_raises(Idnx::Error) do
      Idnx.convert("ü" * 2000)
    end
    assert error_pattern =~ error.message, "expect \"#{error.message}\" to contain \"#{error_pattern}\""
  end
end
