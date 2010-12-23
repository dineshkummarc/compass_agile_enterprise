class AddDescToImageAssets < ActiveRecord::Migration
  def self.up
    add_column :image_assets, :description, :string
  end

  def self.down
    remove_column :image_assets, :description
  end
end
