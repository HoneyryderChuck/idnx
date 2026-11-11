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

class BadgeFormatter
  def initialize(output = nil)
    @output = output || $stdout
  end

  def format(result)
    min_thresholds = SimpleCov.minimum_coverage
    covered_percent = result.source_files.covered_percent.round(0)
    color =
      if min_thresholds.any?
        if SimpleCov::CoverageViolations.minimum_overall(result, SimpleCov.minimum_coverage).any?
          "#ff0000"
        else
          "#ffffcc" # green
        end
      else
        "#808080"
      end
    image = RepoSmallBadge::Image.new(
      {
        output_path: SimpleCov.coverage_dir,
        value_color: color
      }
    )
    image.badge("total", "total", "#{covered_percent}%")
  end
end

namespace :coverage do
  desc "Aggregates coverage reports"
  task :report do
    next unless ENV.key?("CI")

    require "simplecov"
    require "repo_small_badge"

    puts Dir["coverage/**/.resultset.json"].inspect
    SimpleCov.collate(Dir["coverage/**/.resultset.json"]) do
      skip ".bundle/"
      skip "vendor/"
      skip "test/"
      minimum_coverage 89
      formatter SimpleCov::Formatter::MultiFormatter.new(
        [
          SimpleCov::Formatter::HTMLFormatter,
          BadgeFormatter
        ]
      )
    end
  end
end
