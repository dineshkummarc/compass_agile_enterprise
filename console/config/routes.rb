Console::Engine.routes.draw do
  match '/erp_app/desktop/(/:action(.:format))' => "erp_app/desktop/base"
end
