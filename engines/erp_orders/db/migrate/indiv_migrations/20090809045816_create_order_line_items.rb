class CreateOrderLineItems < ActiveRecord::Migration
  def self.up
    create_table :order_line_items do |t|

      	t.column  	:order_txn_id,      		  :integer
      	t.column  	:order_line_item_type_id, :integer      
		      
      	t.column  	:product_id,      			  :integer      
      	t.column  	:product_description,		  :string
      	
      	t.column	  :inventory_item_id, 		  :integer
      	t.column	  :inventory_description,	  :string

      	t.column  	:sold_price, 				      :float 
      	t.column	  :sold_price_uom, 			    :integer
      	
      	t.column  	:sold_amount, 				    :integer
      	t.column    :sold_amount_uom, 		    :integer 

      	t.column    :offer_id,      			    :integer 
      	
      	t.timestamps

    end
  end

  def self.down
    drop_table :order_line_items
  end
end
