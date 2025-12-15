# frozen_string_literal: true

D = Steep::Diagnostic

target :lib do
  check "lib"
  signature "sig"

  library "ffi"

  configure_code_diagnostics do |config|
    config[D::Ruby::UnknownConstant] = :hint
  end
end
