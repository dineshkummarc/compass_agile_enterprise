Rails.application.routes.draw do
  mount ErpAgreements::Engine => "/erp_agreements"
  mount ErpTechSvcs::Engine => "/erp_tech_svcs"
end
