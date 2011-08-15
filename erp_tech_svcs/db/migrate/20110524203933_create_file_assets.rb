class CreateFileAssets < ActiveRecord::Migration
  def self.up
    unless table_exists?(:file_assets)
      create_table :file_assets do |t|
        t.references :file_asset_holder, :polymorphic => true
        t.string :type
        t.string :name
        t.string :directory
        t.string :data_file_name
        t.string :data_content_type
        t.integer :data_file_size
        t.datetime :data_updated_at

        t.timestamps
      end
    end
  end

  def self.down
    if table_exists?(:file_assets)
      drop_table :file_assets
    end
  end
end
