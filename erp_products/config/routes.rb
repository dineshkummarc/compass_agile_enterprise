ErpProducts::Engine.routes.draw do
  #product_manager
  match '/erp_app/desktop/product_manager(/:action(/:id))' => 'erp_app/desktop/product_manager/base'
end