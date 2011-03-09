class AddDefaultImageUrlToProductTypes < ActiveRecord::Migration
  def self.up
    add_column :product_types, :default_image_url, :string
  end

  def self.down
    remove_column :product_types, :default_image_url
  end
end
