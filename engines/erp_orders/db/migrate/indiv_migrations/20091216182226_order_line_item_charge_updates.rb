class OrderLineItemChargeUpdates < ActiveRecord::Migration
  def self.up


#*******************************************************************
# We are changing from inventory items to product types, instances
# and inventory entries. 
#
# This migration will be collapsed with the base order_line_item
# migration.
#*******************************************************************

    remove_column :order_line_items, :inventory_item_id
    remove_column :order_line_items, :inventory_description        
    
    add_column :order_line_items, :product_instance_id, :integer
    add_column :order_line_items, :product_instance_description, :string
    
    add_column :order_line_items, :product_type_id, :integer
    add_column :order_line_items, :product_type_description, :string
    
  end

  def self.down

#*******************************************************************
# Revert changes
#*******************************************************************

    add_column :order_line_items, :inventory_item_id, :integer
    add_column :order_line_items, :inventory_description, :string  

    remove_column :order_line_items, :product_instance_id
    remove_column :order_line_items, :product_instance_description

    remove_column :order_line_items, :product_type_id
    remove_column :order_line_items, :product_type_description    
    
  end
end
