$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "erp_tech_svcs/version"

# Provide a simple gemspec so you can easily use your
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "erp_tech_svcs"
  s.version     = ErpTechSvcs::VERSION::STRING
  s.summary     = "This engine is implemented with the premise that services like logging, tracing and encryption would likely already exist in many organizations, so they are factored here so they can easily be re-implemented."
  s.description = "This engine is implemented with the premise that services like logging, tracing and encryption would likely already exist in many organizations, so they are factored here so they can easily be re-implemented. There are default implementations here, and we track several excellent Rails projects as potential implementations of services like security and content/digital asset mgt."
  s.authors     = ["Rick Koloski, Russell Holmes"]
  s.email       = ["russonrails@gmail.com"]
  s.homepage    = "http://development.compassagile.com"
  
  s.files = Dir["{app,config,db,lib,tasks}/**/*"] + ["GPL-3-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]
  
  #compass dependencies
  s.add_dependency 'erp_base_erp_svcs', "3.0.1"
  s.add_development_dependency 'erp_dev_svcs', "3.0.1"
  
  s.add_dependency('aws-sdk','1.3.9')
  s.add_dependency('delayed_job','2.1.4')
  s.add_dependency('paperclip','3.0.2')
  s.add_dependency('pdfkit','0.4.6')
  s.add_dependency('sorcery','0.7.7')
end
