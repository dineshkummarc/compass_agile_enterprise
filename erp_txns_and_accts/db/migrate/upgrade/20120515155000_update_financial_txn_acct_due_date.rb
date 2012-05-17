class UpdateFinancialTxnAcctDueDate < ActiveRecord::Migration
  def up
    change_column(:financial_txn_accounts, :due_date, :date)
  end

  def down
    change_column(:financial_txn_accounts, :due_date, :datetime)
  end
end
