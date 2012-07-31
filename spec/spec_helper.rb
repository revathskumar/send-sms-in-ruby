require "simplecov"
require "simplecov-rcov"
require 'webmock/rspec'

SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start do
  add_filter "vendor"
  add_filter "spec"
end if ENV["COVERAGE"]
