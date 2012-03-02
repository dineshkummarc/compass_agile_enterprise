$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "compass_ae_console/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "compass_ae_console"
  s.version     = CompassAeConsole::VERSION
  s.summary     = "Rails Console for Compass AE Desktop"
  s.description = "Compass AE Console is an application that sits on top of the Compass AE framework that allows the user to interact with their rails application with a simulated rails console."
  s.authors     = ["Rick Koloski, Christopher Woodward"]
  s.email       = ["russonrails@gmail.com"]
  s.homepage    = "http://development.compassagile.com"

  s.files = Dir["{public,app,config,db,lib,tasks}/**/*"] + ["GPL-3-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  #compass dependencies
  s.add_dependency 'erp_app'
  s.add_development_dependency 'erp_dev_svcs'

  s.add_dependency "rails", "~> 3.1.0"
  s.add_development_dependency("rspec-rails", "~> 2.5")
  s.add_development_dependency "sqlite3"
end
