$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "erp_inventory/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "erp_inventory"
  s.version     = ErpInventory::VERSION
  s.summary     = "The Inventory Engine in CompassAE implements a set of models for storing information about the availability and location of ProductTypes and optionally Product Instances. "
  s.description = "The Inventory Engine in CompassAE implements a set of models for storing information about the availability and location of ProductTypes and optionally Product Instances. It is also the root for yield and revenue management requirements to segment and allocate inventory for different purposes."
  s.authors     = ["Rick Koloski, Russell Holmes"]
  s.email       = ["russonrails@gmail.com"]
  s.homepage    = "http://development.compassagile.com"

  s.files = Dir["{app,config,db,lib,tasks}/**/*"] + ["GPL-3-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  #compass dependencies
  s.add_dependency "erp_app"
  s.add_dependency "erp_agreements"
  s.add_dependency "erp_txns_and_accts"
  s.add_dependency "erp_orders"
  s.add_dependency "erp_products"

  s.add_development_dependency "erp_dev_svcs"
end
