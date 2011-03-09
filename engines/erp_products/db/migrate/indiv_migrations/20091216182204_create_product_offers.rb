class CreateProductOffers < ActiveRecord::Migration
  def self.up
    create_table :product_offers do |t|

      t.column  :description,                 :string
	    					
	    t.column  :product_offer_record_id,     :integer
	    t.column  :product_offer_record_type,   :string
	
			t.column 	:external_identifier, 	      :string
			t.column 	:external_id_source, 	        :string

      t.timestamps
    end
  end

  def self.down
    drop_table :product_offers
  end
end
