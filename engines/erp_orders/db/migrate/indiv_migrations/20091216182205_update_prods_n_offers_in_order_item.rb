class UpdateProdsNOffersInOrderItem < ActiveRecord::Migration
  def self.up

    add_column :order_line_items, :product_offer_id, :string
    remove_column :order_line_items, :offer_id

  end

  def self.down
    
    add_column :order_line_items, :offer_id, :string
    remove_column :order_line_items, :product_offer_id    
    
  end
end
