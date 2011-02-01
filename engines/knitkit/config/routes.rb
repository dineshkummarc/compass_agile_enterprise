ActionController::Routing::Routes.draw do |map|
  #Desktop Applications

  #knitkit
  map.connect '/erp_app/desktop/knitkit/:action', :controller => 'erp_app/desktop/knitkit/base'
  map.connect '/erp_app/desktop/knitkit/image_assets/:action', :controller => 'erp_app/desktop/knitkit/image_assets'
  
end


