class CreateBizTxnTasks < ActiveRecord::Migration
  def self.up
    create_table :biz_txn_tasks do |t|

      t.column  :description, :string
      
      t.timestamps

    end
  end

  def self.down
    drop_table :biz_txn_tasks
  end
end
