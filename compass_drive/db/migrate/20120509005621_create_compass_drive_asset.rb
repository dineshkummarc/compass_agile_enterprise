class CreateCompassDriveAsset < ActiveRecord::Migration
  def up
    unless table_exists?(:compass_drive_assets)
      create_table :compass_drive_assets do |t|
        t.references :file_asset
        t.text       :comment
        t.boolean    :checked_out
        t.integer    :checkout_out_by_id
        t.datetime   :last_checkout_at
        t.string     :name

        t.timestamps
      end

      add_index :compass_drive_assets, :file_asset_id, :name => 'compass_drive_asset_file_asset_idx'
      add_index :compass_drive_assets, :checkout_out_by_id, :name => 'compass_drive_asset_checked_out_by_idx'
      add_index :compass_drive_assets, :checked_out, :name => 'compass_drive_asset_checked_out_idx'

      CompassDriveAsset.create_versioned_table

      #add_index :compass_drive_versions, :file_asset_id, :name => 'compass_drive_asset_v_file_asset_idx'
      #add_index :compass_drive_versions, :checkout_out_by_id, :name => 'compass_drive_v_asset_checked_out_by_idx'
      #add_index :compass_drive_versions, :checked_out, :name => 'compass_drive_asset_v_checked_out_idx'
    end
  end

  def down
    if table_exists?(:compass_drive_assets)
      CompassDriveAsset.drop_versioned_table
      drop_table :compass_drive_assets
    end
  end
end
