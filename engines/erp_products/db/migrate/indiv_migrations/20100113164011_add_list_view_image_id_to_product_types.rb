class AddListViewImageIdToProductTypes < ActiveRecord::Migration
  def self.up
    add_column :product_types, :list_view_image_id, :integer
  end

  def self.down
    remove_column :product_types, :list_view_image_id
  end
end
