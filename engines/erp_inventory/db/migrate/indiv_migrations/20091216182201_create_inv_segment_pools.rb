class CreateInvSegmentPools < ActiveRecord::Migration
  def self.up
    create_table :inv_segment_pools do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :inv_segment_pools
  end
end
