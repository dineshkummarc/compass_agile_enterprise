$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "erp_dev_svcs/version"

# Provide a simple gemspec so you can easily use your
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "erp_dev_svcs"
  s.version = ErpDevSvcs::VERSION
  s.summary = "Insert ErpDevSvcs summary."
  s.description = "Insert ErpDevSvcs description."
  
  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]
  
  s.add_dependency "rails", "~> 3.1.0"
  
  s.add_development_dependency("rspec-rails", "~> 2.5")
  s.add_development_dependency "sqlite3"
end