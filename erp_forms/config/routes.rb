ErpForms::Engine.routes.draw do
  #dynamic_forms
  match '/erp_app/desktop/dynamic_forms/data/:action(/:model_name)' => 'erp_app/desktop/dynamic_forms/data'
  match '/erp_app/desktop/dynamic_forms/forms/:action' => 'erp_app/desktop/dynamic_forms/forms'
  match '/erp_app/desktop/dynamic_forms/models/:action' => 'erp_app/desktop/dynamic_forms/models'
end
