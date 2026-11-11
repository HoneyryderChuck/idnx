# frozen_string_literal: true

SimpleCov.skip ".bundle/"
SimpleCov.skip "vendor/"
SimpleCov.skip "test/"
SimpleCov.command_name "#{RUBY_PLATFORM}/#{RUBY_ENGINE}-#{RUBY_VERSION}"
SimpleCov.coverage_dir ENV.fetch("COVERAGE_DIR") { "coverage/#{RUBY_PLATFORM}/#{RUBY_ENGINE}-#{RUBY_VERSION}" }
