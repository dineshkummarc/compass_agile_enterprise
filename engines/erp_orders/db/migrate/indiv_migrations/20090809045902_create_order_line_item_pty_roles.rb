class CreateOrderLineItemPtyRoles < ActiveRecord::Migration
  def self.up
    create_table :order_line_item_pty_roles do |t|

      t.column  :description,               :string 
      
      t.column  :order_line_item_id,      	:integer  
      t.column  :party_id,                  :integer    
      t.column  :line_item_role_type_id,    :integer
 
      t.column  :bix_txn_acct_root_id,      :integer 	#optional for splitting orders across accounts

      t.timestamps

    end
  end

  def self.down
    drop_table :order_line_item_pty_roles
  end
end
