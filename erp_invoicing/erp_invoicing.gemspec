$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "erp_invoicing/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "erp_invoicing"
  s.version     = ErpInvoicing::VERSION
  s.summary     = "ErpInvoicing adds models and services to the CompassAE core to handle invoicing and billing functions."
  s.description = "ErpInvoicing adds models and services to the CompassAE core to handle invoicing and billing functions. It includes extensions to the core ERP classes for accounts and things that are 'billable' (products, work efforts), and additional models for the invoices/items, payments and the application of payments to invoices or invoice items. It also includes application hooks to make it easy to add electronic bill pay functionality to Web applications."
  s.authors     = ["Rick Koloski, Russell Holmes"]
  s.email       = ["russonrails@gmail.com"]
  s.homepage    = "http://development.compassagile.com"

  s.files = Dir["{public,app,config,db,lib,tasks,public}/**/*"] + ["GPL-3-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  #compass dependencies
  s.add_dependency "erp_app"
  s.add_dependency "erp_agreements"
  s.add_dependency "erp_txns_and_accts"
  s.add_dependency "erp_orders"
  s.add_dependency "erp_products"
  s.add_dependency "erp_inventory"
  s.add_dependency "erp_commerce"

  s.add_development_dependency "sqlite3"
end
