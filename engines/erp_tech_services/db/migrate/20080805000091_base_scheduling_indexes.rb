class BaseSchedulingIndexes < ActiveRecord::Migration
  def self.up
    add_index :delayed_jobs, :run_at
  end

  def self.down
    remove_index :delayed_jobs, :run_at
  end
end