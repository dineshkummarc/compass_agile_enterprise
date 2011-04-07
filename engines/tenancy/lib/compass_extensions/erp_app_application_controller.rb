ErpApp::ApplicationController.class_eval do
  #tenancy plugin, sets schema for tenant
  check_tenants
end