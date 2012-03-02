class AddTypeColumnToBizTxnAcctRoot < ActiveRecord::Migration
  def change
    unless columns(:biz_txn_acct_roots).collect {|c| c.name}.include?('type')
      add_column :biz_txn_acct_roots, :type, :string
    end
  end
end
