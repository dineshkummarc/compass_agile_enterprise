$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "erp_search/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "erp_search"
  s.version     = ErpSearch::VERSION::STRING
  s.summary     = "The CompassAE Search Engine provides functionality to facilitate both dimensional and index-based searches. "
  s.description = "The CompassAE Search Engine provides functionality to facilitate both dimensional and index-based searches. CompassAE by default will search for an instance of SOLR/Sunspot and use it if it is available, otherwise it will attempt to use SQL to implement content searches. This engine also contains a demonstration of how to implement a denormalized search fact table using the Party entity."
  s.authors     = ["Rick Koloski, Russell Holmes"]
  s.email       = ["russonrails@gmail.com"]
  s.homepage    = "http://development.compassagile.com"

  s.files = Dir["{app,config,db,lib,tasks}/**/*"] + ["GPL-3-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "sunspot_rails", "1.3.0"
  s.add_dependency "sunspot_solr", "1.3.0"

  #compass dependencies
  s.add_dependency "knitkit", "2.0.2"
end
