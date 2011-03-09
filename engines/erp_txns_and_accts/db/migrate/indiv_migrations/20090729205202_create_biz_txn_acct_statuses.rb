class CreateBizTxnAcctStatuses < ActiveRecord::Migration
  def self.up
    create_table :biz_txn_acct_statuses do |t|


      t.timestamps

    end
  end

  def self.down
    drop_table :biz_txn_acct_statuses
  end
end
