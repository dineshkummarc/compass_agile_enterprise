class AddPasswordLockCountColumn < ActiveRecord::Migration
  def self.up
    add_column :users, :lock_count, :integer, :default => 0

  end

  def self.down
    remove_column :users, 'lock_count'
  end
end
