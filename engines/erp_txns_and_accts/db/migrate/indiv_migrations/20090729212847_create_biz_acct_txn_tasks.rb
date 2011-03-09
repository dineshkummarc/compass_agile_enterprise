class CreateBizAcctTxnTasks < ActiveRecord::Migration
  def self.up
    create_table :biz_acct_txn_tasks do |t|

		t.column  :biz_txn_task_id, 	:integer
		t.column  :biz_txn_account_id, 	:integer
		t.column  :description, 		:string
		t.column  :comments, 			:string
		t.column  :entered_date,      	:datetime
		t.column  :requested_date,     	:datetime

      	t.timestamps

    end
  end

  def self.down
    drop_table :biz_acct_txn_tasks
  end
end
