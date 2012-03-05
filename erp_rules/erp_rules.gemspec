$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "erp_rules/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "erp_rules"
  s.version     = ErpRules::VERSION::STRING
  s.summary     = "The Rules Module of CompassAE includes classes which act as helpers in externalizing the execution context of CompassAE value objects for processing by a rules engine."
  s.description = "The Rules Module of CompassAE includes classes which act as helpers in externalizing the execution context of CompassAE value objects for processing by a rules engine. It also includes an integration with Ruleby, which is a pure ruby implementation of the forward chaining Rete algorithm."
  s.authors     = ["Rick Koloski, Russell Holmes"]
  s.email       = ["russonrails@gmail.com"]
  s.homepage    = "http://development.compassagile.com"

  s.files = Dir["{app,config,db,lib,tasks}/**/*"] + ["GPL-3-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "ruleby"

  #compass dependencies
  s.add_dependency "erp_txns_and_accts", "3.0.1"

  s.add_development_dependency "erp_dev_svcs", "3.0.1"
end
