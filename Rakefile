# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

require "rubocop/rake_task"

RuboCop::RakeTask.new

if RUBY_VERSION > "3.0.0"
  task :type_check do
    # Steep doesn't provide Rake integration yet,
    # but can do that ourselves
    require "steep"
    require "steep/cli"

    Steep::CLI.new(argv: ["check"], stdout: $stdout, stderr: $stderr, stdin: $stdin).run
  end

  task default: %i[test type_check rubocop]
else
  task default: %i[test]
end
