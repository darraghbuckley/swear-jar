require 'rspec/core/rake_task'
require 'rubocop/rake_task'

require "#{__dir__}/swear_jar"

task default: :test

# :nocov:
desc 'Run all tests.'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = Dir['test/**/*_test.rb']
end
# :nocov:

desc 'Check style.'
RuboCop::RakeTask.new

# :nocov:
task :test do
  task(:spec).invoke
  task(:rubocop).invoke
end
# :nocov:
