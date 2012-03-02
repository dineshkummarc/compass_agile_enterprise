RailsDbAdmin::Engine.routes.draw do
  match '/erp_app/desktop/base(/:action(/:table(/:id)))' => "erp_app/desktop/base"
  match '/erp_app/desktop/queries(/:action(/:table(/:id)))' => "erp_app/desktop/queries"
end
