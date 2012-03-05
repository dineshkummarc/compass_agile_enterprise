$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "erp_txns_and_accts/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "erp_txns_and_accts"
  s.version     = ErpTxnsAndAccts::VERSION::STRING
  s.summary     = "The Transactions and Accounts Engine implements the root classes for adding business transactions and accounts to parties."
  s.description = "The Transactions and Accounts Engine implements the root classes for adding business transactions and accounts to parties. The key marker interface classes here are BizTxnEvent, which represents a common interface for all manner of management accounting transactions, and BixTxnAcctRoot, which is the root class for the accounting of transactions. CompassAE uses separate structures for management and financial accounting. "
  s.authors     = ["Rick Koloski, Russell Holmes"]
  s.email       = ["russonrails@gmail.com"]
  s.homepage    = "http://development.compassagile.com"

  s.files = Dir["{app,config,db,lib,tasks}/**/*"] + ["GPL-3-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]
  
  #compass dependencies
  s.add_dependency "erp_app", "3.0.1"
  s.add_dependency "erp_agreements", "3.0.1"
  s.add_dependency "erp_orders", "3.0.1"

  s.add_development_dependency "erp_dev_svcs", "3.0.1"
end
