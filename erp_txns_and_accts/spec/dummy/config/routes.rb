Rails.application.routes.draw do
  mount ErpTxnAndAccts::Engine => "/erp_txns_and_accts"
end
