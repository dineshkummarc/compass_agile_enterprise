class CreateBizTxnEventDescs < ActiveRecord::Migration
  def self.up
    create_table :biz_txn_event_descs do |t|

		t.column		:biz_txn_event_id,      :integer
		t.column		:language_id,       	:integer
		t.column		:locale_id,		       	:integer
		t.column		:priority,      		:integer		
		t.column		:sequence,      		:integer		
		t.column		:short_description,     :string
		t.column		:long_description,      :string
		
      	t.timestamps

    end
  end

  def self.down
    drop_table :biz_txn_event_descs
  end
end
