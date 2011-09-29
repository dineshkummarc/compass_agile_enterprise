Rails.application.routes.draw do
  mount ErpApp::ErpTechSvcs => "/erp_tech_svcs"
  mount ErpApp::Engine => "/erp_app"
end
