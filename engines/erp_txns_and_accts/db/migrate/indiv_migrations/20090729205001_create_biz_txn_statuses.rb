class CreateBizTxnStatuses < ActiveRecord::Migration
  def self.up
    create_table :biz_txn_statuses do |t|

      t.column  :description, :string
      t.column  :comments, :string

      t.timestamps

    end
  end

  def self.down
    drop_table :biz_txn_statuses
  end
end
