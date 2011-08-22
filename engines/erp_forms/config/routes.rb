ActionController::Routing::Routes.draw do |map|

  #dynamic_forms
  map.connect '/erp_app/desktop/dynamic_forms/data/:action', :controller => 'erp_app/desktop/dynamic_forms/data'
  map.connect '/erp_app/desktop/dynamic_forms/data/:action/:model_name', :controller => 'erp_app/desktop/dynamic_forms/data'
  map.connect '/erp_app/desktop/dynamic_forms/forms/:action', :controller => 'erp_app/desktop/dynamic_forms/forms'
  map.connect '/erp_app/desktop/dynamic_forms/models/:action', :controller => 'erp_app/desktop/dynamic_forms/models'
  
end