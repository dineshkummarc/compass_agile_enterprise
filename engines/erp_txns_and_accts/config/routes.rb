ActionController::Routing::Routes.draw do |map|
  map.resources :erp_txns_and_accts, :controller => "erp_txns_and_accts/erp_txns_and_accts" do |erp_txns_and_accts|

  end
end