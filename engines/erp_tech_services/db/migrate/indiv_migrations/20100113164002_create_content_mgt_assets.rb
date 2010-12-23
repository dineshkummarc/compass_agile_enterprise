class CreateContentMgtAssets < ActiveRecord::Migration
  def self.up
    create_table :content_mgt_assets do |t|

      t.column    :digital_asset_id,    :integer
      t.column    :digital_asset_type,  :string
      t.column    :description,    :string

      t.timestamps
    end
  end

  def self.down
    drop_table :content_mgt_assets
  end
end
