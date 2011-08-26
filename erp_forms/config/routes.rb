ErpForms::Engine.routes.draw do
  #dynamic_forms
  match '/erp_app/desktop/dynamic_forms/data/:action', :controller => 'erp_app/desktop/dynamic_forms/data'
  match '/erp_app/desktop/dynamic_forms/data/:action/:model_name', :controller => 'erp_app/desktop/dynamic_forms/data'
  match '/erp_app/desktop/dynamic_forms/forms/:action', :controller => 'erp_app/desktop/dynamic_forms/forms'
  match '/erp_app/desktop/dynamic_forms/models/:action', :controller => 'erp_app/desktop/dynamic_forms/models'
end
