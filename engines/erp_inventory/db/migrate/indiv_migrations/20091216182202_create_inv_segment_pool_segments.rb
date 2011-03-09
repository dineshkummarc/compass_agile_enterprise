class CreateInvSegmentPoolSegments < ActiveRecord::Migration
  def self.up
    create_table :inv_segment_pool_segments do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :inv_segment_pool_segments
  end
end
