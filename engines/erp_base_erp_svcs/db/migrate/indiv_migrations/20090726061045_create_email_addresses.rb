class CreateEmailAddresses < ActiveRecord::Migration
	def self.up
	  create_table :email_addresses do |t|
	
			t.column    :email_address,     	:string
			t.column    :description,       	:string
			
			t.timestamps
	
	  end
	end

	def self.down
		drop_table :email_addresses
	end
end
