$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "erp_base_erp_svcs/version"

# Provide a simple gemspec so you can easily use your
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "erp_base_erp_svcs"
  s.version     = ErpBaseErpSvcs::VERSION::STRING
  s.summary     = "contains an implementation of the ubiquitous 'party model' for managing people, organizations, roles, relationships and contact information."
  s.description = "contains an implementation of the ubiquitous 'party model' for managing people, organizations, roles, relationships and contact information. The models in this library are designed to be useful in a variety of circumstances, including headless SOA implementations and batch operations."
  s.authors     = ["Rick Koloski, Russell Holmes"]
  s.email       = ["russonrails@gmail.com"]
  s.homepage    = "http://development.compassagile.com"
  
  s.files       = Dir["{app,config,db,lib,tasks}/**/*"] + ["GPL-3-LICENSE", "Rakefile", "README.md"]
  s.test_files  = Dir["spec/**/*"]

  #this is needed for awesome_nested_set it will try to install rails 3.2
  s.add_dependency 'railties', "~> 3.1.0"
  s.add_dependency 'actionmailer', "~> 3.1.0"
  s.add_dependency 'actionpack', "~> 3.1.0"
  s.add_dependency 'activerecord', "~> 3.1.0"
  s.add_dependency 'activeresource', "~> 3.1.0"
  s.add_dependency 'activesupport', "~> 3.1.0"
  s.add_dependency 'rails', "~> 3.1.0"
  s.add_dependency('attr_encrypted','1.2.0')
  s.add_dependency('awesome_nested_set','2.0.2')
  s.add_dependency('data_migrator','1.7')
  s.add_dependency('has_many_polymorphic','>= 2.0.1')
  s.add_dependency('uuid','2.3.4')
  #nasty I know

  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "factory_girl_rails", "1.3.0"
  s.add_development_dependency "rspec-rails", "2.7"
  s.add_development_dependency "simplecov", "0.5"
  s.add_development_dependency "spork", "0.9.0.rc"
  s.add_development_dependency "sqlite3", "1.3.4"
  s.add_development_dependency "watchr"
end
