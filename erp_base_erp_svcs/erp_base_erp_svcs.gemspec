# Provide a simple gemspec so you can easily use your
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "erp_base_erp_svcs"
  s.summary = "Insert ErpBaseErpSvcs summary."
  s.description = "Insert ErpBaseErpSvcs description."
  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]
  s.version = "0.0.1"
  s.add_development_dependency("rspec-rails", "~> 2.5")
  s.add_dependency('data_migrator')
  s.add_dependency('has_many_polymorphic')
  s.add_dependency('attr_encrypted')
  s.add_dependency('awesome_nested_set')
end