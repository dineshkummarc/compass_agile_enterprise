class PaymentApplication < ActiveRecord::Base
  
  belongs_to  :financial_txn, :dependent => :destroy
  belongs_to  :payment_applied_to, :polymorphic => true
  belongs_to  :money, :foreign_key => 'applied_money_amount_id'

  def is_pending?
    self.financial_txn.nil? ? false : self.financial_txn.is_pending?
  end
  
end
