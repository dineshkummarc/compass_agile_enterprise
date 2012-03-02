Money.class_eval do
  has_many :financial_txn_accounts, :foreign_key => 'balance_id'
  has_many :financial_txn_accounts, :foreign_key => 'payment_due_id'
  has_many :financial_txns
end
