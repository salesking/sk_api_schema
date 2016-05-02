# encoding: utf-8
$:.unshift(File.dirname(__FILE__))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'simplecov'
SimpleCov.start do
  add_filter "/json/"
end
SimpleCov.coverage_dir 'coverage'

require 'rubygems'
require 'rspec'
require 'sk_api_schema'
require 'json_schema_validator'

RSpec.configure do |config|
end