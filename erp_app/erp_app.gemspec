$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "erp_app/version"

# Provide a simple gemspec so you can easily use your
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "erp_app"
  s.version     = ErpApp::VERSION::STRING
  s.summary     = "Provides an application infrastructure based on the Sencha/extjs UI framework, as well as several utilities and example applications. "
  s.description = "Provides an application infrastructure based on the Sencha/extjs UI framework, as well as several utilities and example applications. It houses the core application container framework and component model infrastructure that play a key role in the RAD/Agile orientation of CompassAE."
  s.authors     = ["Rick Koloski, Russell Holmes"]
  s.email       = ["russonrails@gmail.com"]
  s.homepage    = "http://development.compassagile.com"

  s.files = Dir["{public,app,config,db,lib,tasks}/**/*"] + ["GPL-3-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency 'will_paginate', '3.0.2'
  s.add_dependency 'uglifier', '~> 1.0.3'
  #s.add_dependency 'therubyracer' # needed on Linux for javascript

  #compass dependencies
  s.add_dependency 'erp_tech_svcs', "3.0.1"

  #dev dependencies
  s.add_development_dependency 'erp_dev_svcs', "3.0.1"
end
