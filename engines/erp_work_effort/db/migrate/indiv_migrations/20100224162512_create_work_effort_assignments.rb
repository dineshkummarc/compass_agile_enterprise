class CreateWorkEffortAssignments < ActiveRecord::Migration
  def self.up
    create_table :work_effort_assignments do |t|
      t.datetime :assigned_at
      t.datetime :unassigned_at

      #Polymorphic Columns
      t.integer :assigned_to_id
      t.string  :assigned_to_type
      t.integer :assigned_by_id
      t.string  :assigned_by_type

      t.timestamps
    end
  end

  def self.down
    drop_table :work_effort_assignments
  end
end
