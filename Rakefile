require 'rubygems'
require 'rake'
require 'rdoc/task'
require 'rspec'
require 'rspec/core/rake_task'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "sk_api_schema"
    gem.summary = %Q{SalesKing API JSON Schema}
    gem.description = %Q{The SalesKing JSON Schema describes our business API in terms of available objects, their fields and links to url endpoints with related objects. Besides ruby users can use a smal lib with utility methods to load and test the schema files.}
    gem.email = "gl@salesking.eu"
    gem.homepage = "http://github.com/salesking/sk_api_schema"
    gem.authors = ["Georg Leciejewski"]
    gem.add_dependency 'activesupport'
    gem.add_development_dependency "rspec"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

desc 'Default: run specs.'
task :default => :spec

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
  # Put spec opts in a file named .rspec in root
end

desc "Generate code coverage"
RSpec::Core::RakeTask.new(:coverage) do |t|
  t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
end

desc 'Generate documentation.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'SalesKing-Api JSON Schema'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
