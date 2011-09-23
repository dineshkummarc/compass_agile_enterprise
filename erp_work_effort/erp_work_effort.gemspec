$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "erp_work_effort/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "erp_work_effort"
  s.version     = ErpWorkEffort::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of ErpWorkEffort."
  s.description = "TODO: Description of ErpWorkEffort."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["GPL-3-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 3.1.0"
  
  # s.add_dependency "jquery-rails"
  
  s.add_development_dependency("rspec-rails", "~> 2.5")
  s.add_development_dependency "sqlite3"
end
