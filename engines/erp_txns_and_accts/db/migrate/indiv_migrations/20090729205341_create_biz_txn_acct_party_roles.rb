class CreateBizTxnAcctPartyRoles < ActiveRecord::Migration
  def self.up
    create_table :biz_txn_acct_party_roles do |t|

      t.column  :description,               		:string 
       
      t.column  :biz_txn_acct_root_id,      		:integer  
      t.column  :party_id,                  		:integer    
      t.column  :biz_txn_acct_pty_rtype_id, 		:integer
      
      t.column  :is_default_billing_acct_flag,   :integer
      
      t.timestamps

    end
  end

  def self.down
    drop_table :biz_txn_acct_party_roles
  end
end
