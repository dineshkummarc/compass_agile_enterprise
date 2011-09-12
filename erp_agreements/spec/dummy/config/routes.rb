Rails.application.routes.draw do
  mount ErpDevSvcs::Engine => "/erp_work_effort"
end
