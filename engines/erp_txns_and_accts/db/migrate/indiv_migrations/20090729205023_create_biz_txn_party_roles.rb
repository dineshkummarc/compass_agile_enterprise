class CreateBizTxnPartyRoles < ActiveRecord::Migration
  def self.up
    create_table :biz_txn_party_roles do |t|

      	t.column  :biz_txn_event_id, 	:integer
    	t.column  :party_id, 			:integer
      	t.column  :role_type_id, 		:integer    	

      	t.timestamps

    end
  end

  def self.down
    drop_table :biz_txn_party_roles
  end
end
