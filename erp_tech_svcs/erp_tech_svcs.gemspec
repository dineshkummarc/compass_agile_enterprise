# Provide a simple gemspec so you can easily use your
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "erp_tech_svcs"
  s.summary = "Insert ErpTechSvcs summary."
  s.description = "Insert ErpTechSvcs description."
  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]
  s.version = "0.0.1"
  s.add_development_dependency("rspec-rails", "~> 2.5")
  s.add_dependency('devise','1.1.rc0')
  s.add_dependency('paperclip','2.4.1')
  s.add_dependency('delayed_job','2.1.4')
end