class BaseOrdersIndexes < ActiveRecord::Migration
  def self.up
    add_index :order_txns, :order_txn_type_id
      
    add_index :order_txn_types, :parent_id
    
    add_index :order_line_items, :order_txn_id
    add_index :order_line_items, :order_line_item_type_id
    add_index :order_line_items, :product_id
    
    add_index :order_line_item_types, :parent_id
    
    add_index :order_line_item_pty_roles, :order_line_item_id
    add_index :order_line_item_pty_roles, :party_id
    add_index :order_line_item_pty_roles, :line_item_role_type_id
    
    add_index :line_item_role_types, :parent_id
    
    add_index :charge_line_payment_txns, [:payment_txn_id, :payment_txn_type]
    add_index :charge_line_payment_txns, :charge_line_id
    
    ### Conditional checks: since these columns may have been added with a later migration,
    ### we check that the column exists before adding an index on it.

    if columns(:order_txns).collect {|c| c.name }.include?('order_txn_record_id')
      add_index :order_txns, [:order_txn_record_id, :order_txn_record_type], 
                :name => "boi_1"
    end

    if columns(:order_line_items).collect{|c| c.name}.include?('product_instance_id')
      add_index :order_line_items, :product_instance_id
    end

    if columns(:order_line_items).collect{|c| c.name}.include?('product_type_id')
      add_index :order_line_items, :product_type_id
    end

    if columns(:order_line_items).collect{|c| c.name}.include?('product_offer_id')
      add_index :order_line_items, :product_offer_id
    end

    if columns(:order_line_item_pty_roles).collect {|c| c.name}.include?('biz_txn_acct_root_id')
      add_index :order_line_item_pty_roles, :biz_txn_acct_root_id
    end

    if columns(:charge_lines).collect{|c| c.name}.include?('charged_item_id')
      add_index :charge_lines, [:charged_item_id, :charged_item_type], 
                :name => "boi_2"
    end
  end

  def self.down
    remove_index :order_txns, :order_txn_type_id
    
    remove_index :order_txn_types, :parent_id
    
    remove_index :order_line_items, :order_txn_id
    remove_index :order_line_items, :order_line_item_type_id
    remove_index :order_line_items, :product_id
    
    remove_index :order_line_item_types, :parent_id
    
    remove_index :order_line_item_pty_roles, :order_line_item_id
    remove_index :order_line_item_pty_roles, :party_id
    remove_index :order_line_item_pty_roles, :line_item_role_type_id
    
    remove_index :line_item_role_types, :parent_id
    
    ### Conditional checks: since these columns were originally added in a later
    ### migration that may not yet have already been run,
    ### we check that the column exists before removing an index on it.

    if indexes(:order_txns).collect {|i| i.name}.include?('boi_1')
      remove_index :order_txns, :name => "boi_1"
    end
    
    if indexes(:order_line_items).collect {|i| 
      i.name}.include?('index_order_line_items_on_product_instance_id')
      remove_index :order_line_items, :product_instance_id
    end
    
    if indexes(:order_line_items).collect {|i| 
      i.name}.include?('index_order_line_items_on_product_type_id')
      remove_index :order_line_items, :product_type_id
    end
    
    if indexes(:order_line_items).collect {|i| 
      i.name}.include?('index_order_line_items_on_product_offer_id')
      remove_index :order_line_items, :product_offer_id
    end
    
    if indexes(:order_line_item_pty_roles).collect {|i| 
      i.name}.include?('index_order_line_items_on_biz_txn_acct_root_id')
      remove_index :order_line_item_pty_roles, :biz_txn_acct_root_id
    end
    
    if indexes(:charge_lines).collect {|i| i.name}.include?('boi_2')
      remove_index :charge_lines, :name => "boi_2"
    end
    
  end
end
