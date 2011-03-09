class CreateProdInstanceInvEntries < ActiveRecord::Migration
  def self.up
    create_table :prod_instance_inv_entries do |t|
      
      t.column  :product_instance_id,   :integer        
      t.column  :inventory_entry_id,    :integer  
       
      t.timestamps
      
    end
  end

  def self.down
    drop_table :prod_instance_inv_entries
  end
end
