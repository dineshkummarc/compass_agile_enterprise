$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rails_db_admin/version"

# Provide a simple gemspec so you can easily use your
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "rails_db_admin"
  s.version     = RailsDbAdmin::VERSION
  s.summary     = "RailsDB Admin is similar in functionality to PHPMyAdmin and other database browsing and data editing tools. "
  s.description = "RailsDB Admin is similar in functionality to PHPMyAdmin and other database browsing and data editing tools. It uses the CompassAE database connection information to discover the schema for an installation, and generates Extjs UIs for creating queries and performing grid-based data inspection and editing."
  s.authors     = ["Rick Koloski, Russell Holmes"]
  s.email       = ["russonrails@gmail.com"]
  s.homepage    = "http://development.compassagile.com"

  s.files = Dir["{public,app,config,db,lib,tasks}/**/*"] + ["GPL-3-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "erp_app"
  s.add_dependency "erp_forms"
  s.add_development_dependency "erp_dev_svcs"
end
