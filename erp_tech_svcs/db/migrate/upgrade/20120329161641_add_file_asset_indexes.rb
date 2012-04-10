class AddFileAssetIndexes < ActiveRecord::Migration
  def self.up
    unless indexes(:file_assets).collect {|i| i.name}.include?('index_file_assets_on_type')
      add_index :file_assets, :type
    end

    unless indexes(:file_assets).collect {|i| i.name}.include?('file_asset_holder_idx')
      add_index :file_assets, [:file_asset_holder_id, :file_asset_holder_type], :name => 'file_asset_holder_idx'
    end

    unless indexes(:file_assets).collect {|i| i.name}.include?('index_file_assets_on_name')
      add_index :file_assets, :name
    end

    unless indexes(:file_assets).collect {|i| i.name}.include?('index_file_assets_on_directory')
      add_index :file_assets, :directory
    end
  end

  def self.down
  end
end
