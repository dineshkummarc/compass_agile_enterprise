$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "knitkit/version"

# Provide a simple gemspec so you can easily use your
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "knitkit"
  s.version = Knitkit::VERSION
  s.summary = "Insert Knitkit summary."
  s.description = "Insert Knitkit description."
  
  s.files = Dir["{app,config,db,lib}/**/*"] + ["GPL-3-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]
  
  s.add_dependency "rails", "~> 3.1.0"
  s.add_dependency('routing-filter','0.2.4')
  s.add_dependency('nokogiri','1.5.0')
  s.add_dependency('rubyzip','0.9.4')
  s.add_dependency('permalink_fu','1.0.0')
  s.add_dependency('acts-as-taggable-on','2.1.1')
  
  s.add_development_dependency("rspec-rails", "~> 2.5")
  s.add_development_dependency "sqlite3"
end