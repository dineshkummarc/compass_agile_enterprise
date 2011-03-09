class CreateSimpleProductOffers < ActiveRecord::Migration
  def self.up
    create_table :simple_product_offers do |t|

      t.column  :description,   :string
      t.column  :product_id,    :integer
      t.column  :base_price,    :float
      t.column  :uom,           :integer

      t.timestamps
    end
  end

  def self.down
    drop_table :simple_product_offers
  end
end
