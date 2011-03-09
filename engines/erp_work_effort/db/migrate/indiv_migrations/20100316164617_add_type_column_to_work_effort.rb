class AddTypeColumnToWorkEffort < ActiveRecord::Migration
  def self.up
    add_column :work_efforts, :type, :string
  end

  def self.down
    remove_column :work_efforts, :type
  end
end
