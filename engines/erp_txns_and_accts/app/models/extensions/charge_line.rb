ChargeLine.class_eval do
  has_many :financial_txns, :through => :charge_line_payment_txns, :source => :financial_txn,
                            :conditions => ["charge_line_payment_txns.payment_txn_type = ?", 'FinancialTxn']
                            
  def payment_txns
    self.financial_txns
  end
end