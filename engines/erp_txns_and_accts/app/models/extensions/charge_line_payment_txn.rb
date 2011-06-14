ChargeLinePaymentTxn.class_eval do
  belongs_to :financial_txn, :class_name => "FinancialTxn",:foreign_key => "payment_txn_id"
end