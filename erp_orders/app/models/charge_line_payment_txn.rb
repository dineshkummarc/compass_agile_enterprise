class ChargeLinePaymentTxn < ActiveRecord::Base
  belongs_to :charge_line
  belongs_to :payment_txn, :polymorphic => true
  belongs_to :financial_txn, :class_name => "FinancialTxn",:foreign_key => "payment_txn_id"
end