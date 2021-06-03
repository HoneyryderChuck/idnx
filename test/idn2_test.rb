# frozen_string_literal: true

require "test_helper"

class Idn2Test < Minitest::Test
  def test_convert
    idnname = Idn2.convert("bücher.ch")

    assert idnname == "xn--bcher-kva.ch", "waiting for idn version, instead got '#{idnname}'"
  end

  def test_convert_ascii
    idnname = Idn2.convert("google.ch")

    assert idnname == "google.ch", "waiting for 'google.ch', instead got '#{idnname}'"
  end

  def test_convert_error
    error_pattern = /domain name longer than/
    error = assert_raises(Idn2::Error) do
      Idn2.convert("ü" * 2000)
    end
    assert error_pattern =~ error.message, "expect \"#{error.message}\" to contain \"#{error_pattern}\""
  end
end
