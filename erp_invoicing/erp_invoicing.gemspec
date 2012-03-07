$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "erp_invoicing/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "erp_invoicing"
  s.version     = ErpInvoicing::VERSION::STRING
  s.summary     = "ErpInvoicing adds models and services to the CompassAE core to handle invoicing and billing functions."
  s.description = "ErpInvoicing adds models and services to the CompassAE core to handle invoicing and billing functions. It includes extensions to the core ERP classes for accounts and things that are 'billable' (products, work efforts), and additional models for the invoices/items, payments and the application of payments to invoices or invoice items. It also includes application hooks to make it easy to add electronic bill pay functionality to Web applications."
  s.authors     = ["Rick Koloski, Russell Holmes"]
  s.email       = ["russonrails@gmail.com"]
  s.homepage    = "http://development.compassagile.com"

  s.files = Dir["{public,app,config,db,lib,tasks,public}/**/*"] + ["GPL-3-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  #compass dependencies
  s.add_dependency "erp_app", "3.0.1"
  s.add_dependency "erp_agreements", "3.0.1"
  s.add_dependency "erp_txns_and_accts", "3.0.1"
  s.add_dependency "erp_orders", "3.0.1"
  s.add_dependency "erp_products", "3.0.1"
  s.add_dependency "erp_inventory", "3.0.1"
  s.add_dependency "erp_commerce", "3.0.1"

  s.add_development_dependency "erp_dev_svcs", "3.0.1"
end
