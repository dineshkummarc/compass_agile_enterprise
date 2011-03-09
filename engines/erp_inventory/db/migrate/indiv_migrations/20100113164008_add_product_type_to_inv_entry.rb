class AddProductTypeToInvEntry < ActiveRecord::Migration
  def self.up
    add_column :inventory_entries, :product_type_id, :integer    
  end

  def self.down
    remove_column :inventory_entries, :product_type_id  
  end
end
