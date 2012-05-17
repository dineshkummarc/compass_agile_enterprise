$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "erp_dev_svcs/version"

# Provide a simple gemspec so you can easily use your
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "erp_dev_svcs"
  s.version     = ErpDevSvcs::VERSION::STRING
  s.summary     = "This engine exists to serve as a way to organize code that exists to support the development process, but will not live in the running production code."
  s.description = "This engine exists as development support for CompassAE."
  s.authors     = ["Rick Koloski, Russell Holmes"]
  s.email       = ["russonrails@gmail.com"]
  s.homepage    = "http://development.compassagile.com"

  s.files = Dir["{app,config,db,lib,tasks,compass_scripts}/**/*"] + ["GPL-3-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.bindir        = 'bin'
  s.executables   = ['compass-util']

  #compass dependencies
  s.add_dependency 'erp_base_erp_svcs', '3.0.1'

  s.add_dependency "cucumber-rails", "~> 1.1.1"
  s.add_dependency "database_cleaner"
  s.add_dependency "factory_girl_rails", "~> 1.3.0"
  s.add_dependency "rspec-rails", "~> 2.7"
  s.add_dependency "simplecov", "~> 0.5"
  s.add_dependency "spork", "~> 0.9.0.rc"
  s.add_dependency "sqlite3", "~> 1.3.4"
  s.add_dependency "watchr"
end
