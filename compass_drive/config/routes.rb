CompassDrive::Engine.routes.draw do
  #Desktop Applications
  #
  #compass_drive
  match '/erp_app/desktop(/:action(/:id))' => 'erp_app/desktop/base'
end


