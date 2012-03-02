Party.class_eval do

  has_many 	  :invoice_party_roles, :dependent => :destroy
	has_many	  :invoices, :through => :invoice_party_roles

  def billing_accounts
    self.biz_txn_acct_roots.where('biz_txn_acct_type = ?', 'FinancialTxnAccount').collect(&:account).collect(&:financial_account)
  end

end