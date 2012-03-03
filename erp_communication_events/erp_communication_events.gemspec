$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "erp_communication_events/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "erp_communication_events"
  s.version     = ErpCommunicationEvents::VERSION::STRING
  s.summary     = "ErpCommunicationEvents add models and services to CompassAE's ERP core to handle contacts between Business Parties."
  s.description = "ErpCommunicationEvents add models and services to CompassAE's ERP core to handle contacts between Business Parties. For example, tracking inbound or outbound emails, customer contact events, support requests, etc. These models would be used for support and ticketing systems, marketing communications applications and the like. CommunicationEvents can be typed and can relate to one another, providing the functionality to treat several related communication events as a group."
  s.authors     = ["Rick Koloski, Russell Holmes"]
  s.email       = ["russonrails@gmail.com"]
  s.homepage    = "http://development.compassagile.com"

  s.files = Dir["{app,config,db,lib,tasks}/**/*"] + ["GPL-3-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "erp_tech_svcs", "3.0.2"

  s.add_development_dependency "erp_dev_svcs", "3.0.2"
end
