require 'rack/test'
require 'rspec'
require 'simplecov'

SimpleCov.minimum_coverage 100
SimpleCov.start

require "#{__dir__}/../swear_jar"
