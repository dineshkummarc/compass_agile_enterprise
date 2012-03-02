$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "compass_ae_starter_kit/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "compass_ae_starter_kit"
  s.version     = CompassAeStarterKit::VERSION::STRING
  s.summary     = "Gem to help get the Compass AE framework up a running"
  s.description = "Contains serveral rake tasks to get Compass AE running"
  s.authors     = ["Rick Koloski, Russell Holmes"]
  s.email       = ["russonrails@gmail.com"]
  s.homepage    = "http://development.compassagile.com"

  s.files = Dir["{lib,config,public}/**/*"] + ["GPL-3-LICENSE", "README.md"]
  s.bindir      = 'bin'
  s.executables = ['compass_ae']

  s.add_dependency "rails", "~> 3.1.0"
end
