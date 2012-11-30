#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'rspec'
require 'rspec/core/rake_task'
require 'rdoc/task'

desc "Run specs"
RSpec::Core::RakeTask.new
task :default => :spec

desc 'Generate documentation.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'SalesKing-Api JSON Schema'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
