class AddColumnsToWorkEffortAssignment < ActiveRecord::Migration
  def self.up
    add_column :work_effort_assignments, :assigned_from, :DateTime
    add_column :work_effort_assignments, :assigned_to, :DateTime
  end

  def self.down
    remove_column :work_effort_assignments, :assigned_to
    remove_column :work_effort_assignments, :assigned_from
  end
end
