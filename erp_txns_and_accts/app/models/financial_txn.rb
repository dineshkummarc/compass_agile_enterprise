class FinancialTxn < ActiveRecord::Base
  acts_as_biz_txn_event
  has_many   :charge_line_payment_txns, :as => :payment_txn,  :dependent => :destroy
  has_many   :charge_lines, :through => :charge_line_payment_txns
  belongs_to :money, :dependent => :destroy
  has_many   :payments

  def has_captured_payment?
    has_payments? and self.payments.last.current_state == 'captured'
  end

  def has_pending_payment?
    has_payments? and self.payments.last.current_state == 'pending'
  end

  def is_pending?
    !has_payments? || has_pending_payment?
  end

  def has_payments?
    !self.payments.empty?
  end

end
