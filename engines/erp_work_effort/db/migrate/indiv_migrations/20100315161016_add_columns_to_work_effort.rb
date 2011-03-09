class AddColumnsToWorkEffort < ActiveRecord::Migration
  def self.up
    add_column :work_efforts, :description, :string
    add_column :work_efforts, :projected_completion_time, :integer
    add_column :work_efforts, :actual_completion_time, :integer
    add_column :work_efforts, :projected_cost_id, :integer
    add_column :work_efforts, :actual_cost_id, :integer
  end

  def self.down
    remove_column :work_efforts, :actual_cost_id
    remove_column :work_efforts, :projected_cost_id
    remove_column :work_efforts, :actual_completion_time
    remove_column :work_efforts, :projected_completion_time
    remove_column :work_efforts, :description
  end
end
