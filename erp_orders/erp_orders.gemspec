$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "erp_orders/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "erp_orders"
  s.version     = ErpOrders::VERSION::STRING
  s.summary     = "The Orders Engine in CompassAE implements models for Orders, Order Items and Order status tracking."
  s.description = "The Orders Engine in CompassAE implements models for Orders, Order Items and Order status tracking. It also houses models for charge lines associated with Orders (although it could be argued that this functionality should reside in Commerce)."
  s.authors     = ["Rick Koloski, Russell Holmes"]
  s.email       = ["russonrails@gmail.com"]
  s.homepage    = "http://development.compassagile.com"

  s.files = Dir["{public,app,config,db,lib,tasks,public}/**/*"] + ["GPL-3-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  #compass dependencies
  s.add_dependency "erp_products", "3.0.1"
  s.add_dependency "erp_txns_and_accts", "3.0.1"

  s.add_development_dependency "erp_dev_svcs", "3.0.1"
end
