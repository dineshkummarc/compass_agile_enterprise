class BaseInventoryIndexes < ActiveRecord::Migration
  def self.up
    add_index :inventory_entries, [:inventory_entry_record_id, :inventory_entry_record_type], 
              :name => "bii_1"

    add_index :inv_entry_reln_types, :parent_id
    
    add_index :inv_entry_role_types, :parent_id
    
    add_index :inv_entry_relns, :inv_entry_reln_type_id
    add_index :inv_entry_relns, :status_type_id
    
    add_index :prod_instance_inv_entries, :product_instance_id
    add_index :prod_instance_inv_entries, :inventory_entry_id
    
    ### Conditional checks: since these columns may have been added with a later migration,
    ### we check that the column exists before adding an index on it.

    if columns(:inventory_entries).include?('product_type_id')
      add_index :inventory_entries, :product_type_id
    end
  end

  def self.down
    remove_index :inventory_entries, :name => "bii_1"
    
    remove_index :inv_entry_reln_types, :parent_id
    
    remove_index :inv_entry_role_types, :parent_id
    
    remove_index :inv_entry_relns, :inv_entry_reln_type_id
    remove_index :inv_entry_relns, :status_type_id
    
    remove_index :prod_instance_inv_entries, :product_instance_id
    remove_index :prod_instance_inv_entries, :inventory_entry_id

    ### Conditional checks: since these columns were originally added in a later
    ### migration that may not yet have already been run,
    ### we check that the column exists before removing an index on it.

    if indexes(:inventory_entries).collect {|i| 
      i.name}.include?('index_inventory_entries_on_product_type_id')
      remove_index :inventory_entries, :product_type_id
    end
    
  end
end
