$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "erp_forms/version"

# Provide a simple gemspec so you can easily use your
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "erp_forms"
  s.version     = ErpForms::VERSION::STRING
  s.summary     = "ErpForms provides dynamic form capability to existing and dynamic models."
  s.description = "ErpForms provides dynamic form capability to existing and dynamic models. Form Builder coming soon."
  s.authors     = ["Rick Koloski, Russell Holmes"]
  s.email       = ["russonrails@gmail.com"]
  s.homepage    = "http://development.compassagile.com"

  s.files = Dir["{public,app,config,db,lib,tasks}/**/*"] + ["GPL-3-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency('dynamic_attributes','1.2.0')

  #compass dependencies
  s.add_dependency 'erp_app', '3.0.2'

  s.add_development_dependency 'erp_dev_svcs', '3.0.2'
end
