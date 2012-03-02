Rails.application.routes.draw do
  mount ErpTxnsAndAccts::Engine => "/erp_txns_and_accts"
end
