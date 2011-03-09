class CreateBizTxnEvents < ActiveRecord::Migration
  def self.up
    create_table :biz_txn_events do |t|

	    t.column  :description,  			:string
	    	
	    t.column	:biz_txn_acct_root_id, 	:integer
			t.column	:biz_txn_type_id, 		:integer
			
			t.column 	:entered_date, 			:datetime
			t.column 	:post_date, 			:datetime
	
	    t.column  :biz_txn_record_id,    	:integer
	    t.column  :biz_txn_record_type,  	:string
	
			t.column 	:external_identifier, 	:string
			t.column 	:external_id_source, 	:string
	
	    t.timestamps

    end
  end

  def self.down
    drop_table :biz_txn_events
  end
end
