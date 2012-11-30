# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'sk_api_schema/version'

Gem::Specification.new do |s|
  s.version = SK::Api::Schema::VERSION
  s.date = %q{2012-07-27}
  s.name = %q{sk_api_schema}
  s.summary = 'SalesKing API - JSON Schema'
  s.description = %q{The SalesKing JSON Schema describes our business API in terms of available objects, their fields and links to url endpoints with related objects.
Besides ruby users can use a small lib with utility methods to load and test the schema files.}
  s.authors = ['Georg Leciejewski']
  s.email = %q{gl@salesking.eu}
  s.homepage = %q{http://github.com/salesking/sk_api_schema}
  s.extra_rdoc_files = ['README.rdoc']
  s.executables   = nil
  s.files         = `git ls-files`.split("\n").reject{|i| i[/^docs\//] }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ['lib']
  s.rubygems_version = '1.8.24'

  s.add_runtime_dependency 'activesupport'
  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'rake', '>= 0.9.2'

end