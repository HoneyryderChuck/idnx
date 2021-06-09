# frozen_string_literal: true

require "test_helper"

class IdnTest < Minitest::Test
  def test_to_punycode
    idnname = Idnx.to_punycode("bücher.ch")

    assert idnname == "xn--bcher-kva.ch", "waiting for idn version, instead got '#{idnname}'"
  end

  def test_to_punycode_ascii
    idnname = Idnx.to_punycode("google.ch")

    assert idnname == "google.ch", "waiting for 'google.ch', instead got '#{idnname}'"
  end

  def test_to_punycode_error
    error_pattern = FFI::Platform.windows? ? /invalid name was supplied/ : /domain name longer than/
    error = assert_raises(Idnx::Error) do
      Idnx.to_punycode("ü" * 2000)
    end
    assert error_pattern =~ error.message, "expect \"#{error.message}\" to contain \"#{error_pattern}\""
  end
end
