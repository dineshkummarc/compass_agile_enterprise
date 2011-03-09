class CreateBizTxnAcctRoots < ActiveRecord::Migration
  def self.up
    create_table :biz_txn_acct_roots do |t|

		t.column 	:description,			:string
		t.column 	:status, 				:integer
		
    	t.column    :biz_txn_acct_id,    	:integer
    	t.column    :biz_txn_acct_type,  	:string

		t.column 	:external_identifier, 	:string
		t.column 	:external_id_source, 	:string

      	t.timestamps

    end
  end

  def self.down
    drop_table :biz_txn_acct_roots
  end
end
