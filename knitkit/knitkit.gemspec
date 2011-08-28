# Provide a simple gemspec so you can easily use your
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "knitkit"
  s.summary = "Insert Knitkit summary."
  s.description = "Insert Knitkit description."
  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]
  s.version = "0.0.1"
  s.add_development_dependency("rspec-rails", "~> 2.5")
  s.add_dependency('routing-filter')
  s.add_dependency('nokogiri')
  s.add_dependency('rubyzip')
  s.add_dependency('permalink_fu')
  s.add_dependency('acts-as-taggable-on')
end