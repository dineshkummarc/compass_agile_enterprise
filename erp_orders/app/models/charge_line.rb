class ChargeLine < ActiveRecord::Base
  
   belongs_to :charged_item, :polymorphic => true
   belongs_to :money, :dependent => :destroy
   has_many   :charge_line_payment_txns, :dependent => :destroy
   
   def payment_txns
     #this is a stub for extensions
     return []
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
