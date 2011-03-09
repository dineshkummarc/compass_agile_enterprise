class BaseOrders < ActiveRecord::Migration
  def self.up
    
    unless table_exists?(:order_txns)
      create_table :order_txns do |t|
		    t.column    :state_machine,   		:string
		    t.column    :description,     		:string
		    t.column		:order_txn_type_id, 	:integer
		    # Multi-table inheritance info 
		    # MTI implemented using Rails' polymorphic associations    
		    # Contact Information 
		    t.column 		:email,              :string 
		    t.column 		:phone_number,       :string 
		    # Shipping Address 
		    t.column 		:ship_to_first_name,   :string 
		    t.column 		:ship_to_last_name,    :string 
		    t.column 		:ship_to_address, 	   :string 
		    t.column 		:ship_to_city,         :string
		    t.column    :ship_to_state,        :string
		    t.column 		:ship_to_postal_code,  :string 
		    t.column 		:ship_to_country,      :string 
		    # Private parts 
		    t.column 		:customer_ip, 			    :string 
		    t.column    :order_number,          :integer
		    t.column 		:status,                :string 
		    t.column 		:error_message, 		    :string
		    t.column    :order_txn_record_id,   :integer
		    t.column    :order_txn_record_type, :string
		    t.timestamps
      end
    end
    
    unless table_exists?(:order_txn_types)
      create_table :order_txn_types do |t|
        t.column  	:parent_id,    			:integer
        t.column  	:lft,          			:integer
        t.column  	:rgt,          			:integer
        #custom columns go here   
        t.column  :description,         :string
        t.column  :comments,            :string
		    t.column 	:internal_identifier, :string
		    t.column 	:external_identifier, :string
		    t.column 	:external_id_source, 	:string
        t.timestamps
      end
    end
    

    unless table_exists?(:order_line_items)
      create_table :order_line_items do |t|
        t.column  	:order_txn_id,      		        :integer
        t.column  	:order_line_item_type_id,       :integer
        t.column  	:product_id,      			        :integer
        t.column  	:product_description,		        :string
        t.column    :product_instance_id,           :integer
        t.column    :product_instance_description,  :string
        t.column    :product_type_id,               :integer
        t.column    :product_type_description,      :string
        t.column  	:sold_price, 				            :float
        t.column	  :sold_price_uom, 			          :integer
        t.column  	:sold_amount, 				          :integer
        t.column    :sold_amount_uom, 		          :integer
        t.column    :product_offer_id,      	      :integer
        t.timestamps
      end
    end
    
    unless table_exists?(:order_line_item_types)
      create_table :order_line_item_types do |t|
        t.column  	:parent_id,    			:integer
        t.column  	:lft,          			:integer
        t.column  	:rgt,          			:integer
        #custom columns go here   
        t.column  :description,         :string
        t.column  :comments,            :string
		    t.column 	:internal_identifier, :string
		    t.column 	:external_identifier, :string
		    t.column 	:external_id_source, 	:string
        t.timestamps
      end
    end
    
    unless table_exists?(:order_line_item_pty_roles)
      create_table :order_line_item_pty_roles do |t|
        t.column  :description,               :string 
        t.column  :order_line_item_id,      	:integer  
        t.column  :party_id,                  :integer    
        t.column  :line_item_role_type_id,    :integer
        t.column  :biz_txn_acct_root_id,      :integer 	#optional for splitting orders across accounts
        t.timestamps
      end
    end
        
    unless table_exists?(:line_item_role_types)
      create_table :line_item_role_types do |t|
      	t.column  	:parent_id,    			:integer
      	t.column  	:lft,          			:integer
      	t.column  	:rgt,          			:integer
        #custom columns go here   
      	t.column  :description,         :string
      	t.column  :comments,            :string
		    t.column 	:internal_identifier, :string
		    t.column 	:external_identifier, :string
		    t.column 	:external_id_source, 	:string
      	t.timestamps
      end
    end
    
    unless table_exists?(:charge_lines)
      create_table :charge_lines do |t|
        t.string      :sti_type
        t.references  :money_amount
        t.string      :description     #could be expanded to include type information, etc.
        t.string      :external_identifier
        t.string      :external_id_source
        
        #polymorphic
        t.references :charged_item, :polymorphic => true

        t.timestamps
      end  
    end
    
    unless table_exists?(:charge_line_payment_txns)
      create_table :charge_line_payment_txns do |t|
        t.column :charge_line_id, :integer
        
        #polymorphic
        t.references :payment_txn, :polymorphic => true

        t.timestamps
      end
    end
  end

  def self.down
    [
      :charge_lines, :charge_line_payment_txns, :line_item_role_types, :order_line_item_pty_roles,
      :order_line_item_types, :order_line_items, :order_txn_types, 
      :order_txns
    ].each do |tbl|
      if table_exists?(tbl)
        drop_table tbl
      end
    end    
  end
  
end
