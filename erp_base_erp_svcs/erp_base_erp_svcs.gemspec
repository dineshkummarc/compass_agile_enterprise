$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "erp_base_erp_svcs/version"

# Provide a simple gemspec so you can easily use your
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "erp_base_erp_svcs"
  s.version = ErpBaseErpSvcs::VERSION
  s.summary = "Insert ErpBaseErpSvcs summary."
  s.description = "Insert ErpBaseErpSvcs description."
  s.authors     = ["Russell"]
  s.email       = ["rholmes@gmail.com"]
  s.homepage    = "http://www.test.com"
  
  s.files = Dir["{app,config,db,lib}/**/*"] + ["GPL-3-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]
  
  s.add_dependency "rails", "~> 3.1.0"
  s.add_dependency('data_migrator','1.7')
  s.add_dependency('has_many_polymorphic','0.5.0')
  s.add_dependency('attr_encrypted','1.2.0')
  s.add_dependency('awesome_nested_set','2.0.2')
  s.add_dependency('uuid','2.3.4')
  
  s.add_development_dependency("rspec-rails", "~> 2.5")
  s.add_development_dependency "sqlite3"
end