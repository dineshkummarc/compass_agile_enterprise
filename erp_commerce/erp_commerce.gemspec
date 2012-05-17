$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "erp_commerce/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "erp_commerce"
  s.version     = ErpCommerce::VERSION::STRING
  s.summary     = "The CompassAE Commerce Engine uses the engines that implement Parties, Products and Orders, and adds the ability to conduct commerce."
  s.description = "The CompassAE Commerce Engine uses the engines that implement Parties, Products and Orders, and adds the ability to conduct commerce. It implements a pricing engine, fees, payment gateways."
  s.authors     = ["Rick Koloski, Russell Holmes"]
  s.email       = ["russonrails@gmail.com"]
  s.homepage    = "http://development.compassagile.com"

  s.files = Dir["{app,config,db,lib,tasks}/**/*"] + ["GPL-3-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "aasm", "2.3.1"
  s.add_dependency "activemerchant", "1.20.4"

  #compass_ae dependencies
  s.add_dependency "erp_app", "3.0.1"
  s.add_dependency "erp_agreements", "3.0.1"
  s.add_dependency "erp_orders", "3.0.1"
  s.add_dependency "erp_products", "3.0.1"
  s.add_dependency "erp_txns_and_accts", "3.0.1"
  s.add_dependency "prismpay"

  s.add_development_dependency "erp_dev_svcs", "3.0.1"
end
