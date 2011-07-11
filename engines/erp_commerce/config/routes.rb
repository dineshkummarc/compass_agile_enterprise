
ActionController::Routing::Routes.draw do |map|

  #*********************************************************************************************
  # credit cards
  #*********************************************************************************************
  # map.credit_card_private_info '/credit_card_private_info', :controller => "base_apps/ecommerce/credit_card", :action => 'get_credit_card_private_info'
  
  map.resources :credit_cards, :controller => "base_apps/ecommerce/credit_card"
  
end