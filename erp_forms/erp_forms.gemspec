$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "erp_forms/version"

# Provide a simple gemspec so you can easily use your
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "erp_forms"
  s.summary = "Insert ErpForms summary."
  s.version = ErpForms::VERSION
  s.description = "Insert ErpForms description."
  
  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]
  
  s.add_dependency "rails", "~> 3.1.0"
  s.add_dependency('dynamic_attributes','1.2.0')
  
  s.add_development_dependency("rspec-rails", "~> 2.5")
  s.add_development_dependency "sqlite3"
end