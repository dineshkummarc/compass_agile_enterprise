class AlterColumnsOnWorkRequirement < ActiveRecord::Migration
  def self.up
    rename_column :work_requirements, :standard_effort_time, :projected_completion_time
    add_column :work_requirements, :cost_id, :integer
  end

  def self.down
    rename_column :work_requirements, :projected_completion_time, :standard_effort_time
    remove_column :work_requirements, :cost_id, :integer
  end
end
