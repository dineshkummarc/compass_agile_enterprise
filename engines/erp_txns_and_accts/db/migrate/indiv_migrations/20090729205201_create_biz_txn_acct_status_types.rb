class CreateBizTxnAcctStatusTypes < ActiveRecord::Migration
  def self.up
    create_table :biz_txn_acct_status_types do |t|


      t.timestamps

    end
  end

  def self.down
    drop_table :biz_txn_acct_status_types
  end
end
