$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "compass_ae_console/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "compass_ae_console"
  s.version     = CompassAeConsole::VERSION::STRING
  s.summary     = "Rails Console for Compass AE Desktop"
  s.description = "Compass AE Console is an application that sits on top of the Compass AE framework that allows the user to interact with their rails application with a simulated rails console."
  s.authors     = ["Rick Koloski, Christopher Woodward"]
  s.email       = ["russonrails@gmail.com"]
  s.homepage    = "http://development.compassagile.com"

  s.files = Dir["{public,app,config,db,lib,tasks}/**/*"] + ["GPL-3-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  #compass dependencies
  s.add_dependency('erp_app', "3.0.1")

  s.add_development_dependency("erp_dev_svcs", "3.0.1")
  s.add_development_dependency "sqlite3", "~> 1.3.5"
end
