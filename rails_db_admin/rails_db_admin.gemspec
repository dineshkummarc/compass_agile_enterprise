$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rails_db_admin/version"

# Provide a simple gemspec so you can easily use your
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "rails_db_admin"
  s.version = RailsDbAdmin::VERSION
  s.summary = "Insert RailsDbAdmin summary."
  s.description = "Insert RailsDbAdmin description."
  
  s.files = Dir["{app,config,db,lib}/**/*"] + ["GPL-3-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]
  
  s.add_dependency "rails", "~> 3.1.0"
  
  s.add_development_dependency("rspec-rails", "~> 2.5")
  s.add_development_dependency "sqlite3"
end