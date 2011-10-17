Rails.application.routes.draw do
  mount ErpTechSvcs::Engine => "/erp_tech_svcs"
  mount ErpApp::Engine => "/erp_app"
end
