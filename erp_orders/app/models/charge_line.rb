class ChargeLine < ActiveRecord::Base
  
   belongs_to :charged_item, :polymorphic => true
   belongs_to :money
   has_many   :charge_line_payment_txns, :dependent => :destroy
   has_many   :financial_txns, :through => :charge_line_payment_txns, :source => :financial_txn,
                               :conditions => ["charge_line_payment_txns.payment_txn_type = ?", 'FinancialTxn']
   
   def payment_txns
     self.financial_txns
   end
   
   def add_payment_txn(payment_txn)
     charge_line_payment_txn = ChargeLinePaymentTxn.new
     charge_line_payment_txn.charge_line = self
     charge_line_payment_txn.payment_txn = payment_txn
     charge_line_payment_txn.save
     charge_line_payment_txns << charge_line_payment_txn
     self.save
   end

end
