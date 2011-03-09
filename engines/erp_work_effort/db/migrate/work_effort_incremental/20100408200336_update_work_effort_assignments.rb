class UpdateWorkEffortAssignments < ActiveRecord::Migration
  def self.up
    rename_column :work_effort_assignments, :assigned_to, :assigned_thru
  end

  def self.down
    rename_column :work_effort_assignments, :assigned_thru, :assigned_to
  end
end
