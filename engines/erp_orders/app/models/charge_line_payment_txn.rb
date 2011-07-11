class ChargeLinePaymentTxn < ActiveRecord::Base
  belongs_to :charge_line
  belongs_to :payment_txn, :polymorphic => true

end