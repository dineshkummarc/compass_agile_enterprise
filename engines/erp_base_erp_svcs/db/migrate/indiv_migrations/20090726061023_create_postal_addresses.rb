class CreatePostalAddresses < ActiveRecord::Migration
  def self.up
    create_table :postal_addresses do |t|

		t.column    :address_line_1,    :string
		t.column    :address_line_2,    :string
		t.column    :city,              :string
		t.column    :state,             :string
		t.column    :zip,               :string
		t.column    :country,           :string
		t.column    :description,       :string
		
		t.timestamps

    end
  end

	def self.down
		drop_table :postal_addresses
	end
end
