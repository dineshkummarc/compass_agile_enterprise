$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "erp_financial_accounting/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "erp_financial_accounting"
  s.version     = ErpFinancialAccounting::VERSION
  s.summary     = "The CompassAE Financial Accounting Engine implements the basic classes that allow either interface or implementation of general ledger, accounts payable and accounts receivable modules."
  s.description = "The CompassAE Financial Accounting Engine implements the basic classes that allow either interface or implementation of general ledger, accounts payable and accounts receivable modules. This module is experimental at this stage."
  s.authors     = ["Rick Koloski, Russell Holmes"]
  s.email       = ["russonrails@gmail.com"]
  s.homepage    = "http://development.compassagile.com"

  s.files = Dir["{app,config,db,lib,tasks}/**/*"] + ["GPL-3-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "erp_app"
  s.add_dependency "erp_txns_and_accts"
  s.add_dependency "erp_agreements"
  s.add_dependency "erp_products"
  s.add_dependency "erp_orders"
  s.add_dependency "erp_commerce"

  s.add_development_dependency "erp_dev_svcs"
end
