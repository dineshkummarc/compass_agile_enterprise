class CreateOrderTxns < ActiveRecord::Migration
  def self.up
    create_table :order_txns do |t|

		t.column    	:state_machine,   		:string
		t.column    	:description,     		:string
		
		t.column		:order_txn_type_id, 	:integer

		# Multi-table inheritance info 
		# MTI implemented using Rails' polymorphic associations    

		# Contact Information 
		t.column 		:email, 				:string 
		t.column 		:phone_number, 			:string 
		# Shipping Address 
		t.column 		:ship_to_first_name, 	:string 
		t.column 		:ship_to_last_name, 	:string 
		t.column 		:ship_to_address, 		:string 
		t.column 		:ship_to_city, 			:string 
		t.column 		:ship_to_postal_code, 	:string 
		t.column 		:ship_to_country, 		:string 
		# Private parts 
		t.column 		:customer_ip, 			:string 
		t.column 		:status, 				:string 
		t.column 		:error_message, 		:string 

		t.timestamps

    end
  end

  def self.down
    drop_table :order_txns
  end
end
