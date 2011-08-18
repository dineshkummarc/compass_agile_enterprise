Compass::Application.routes.draw do
  devise_for :users, :controllers => {:sessions => 'erp_tech_svcs/sessions'}
end