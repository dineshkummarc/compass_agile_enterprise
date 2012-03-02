ErpInvoicing::Engine.routes.draw do

  match '/sms/receive_response' => "sms#receive_response"

  match '/erp_app/organizer/bill_pay/base(/:action)' => "erp_app/organizer/bill_pay/base#index"
  match '/erp_app/organizer/bill_pay/accounts(/:action)' => "erp_app/organizer/bill_pay/accounts#index"

  #shared
  match '/erp_app/shared/billing_accounts(/:action(/:id))' => "erp_app/shared/billing_accounts"
  match '/erp_app/shared/invoices(/:action(/:id))' => "erp_app/shared/invoices"
  match '/erp_app/shared/invoices/files/:invoice_id(/:action)' => "erp_app/shared/files"
  
end