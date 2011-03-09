class CreateWorkRequirementWorkEffortStatusTypes < ActiveRecord::Migration
  def self.up
    create_table :work_requirement_work_effort_status_types do |t|
      t.timestamps

      #foreign keys
      t.integer :work_requirement_id
      t.integer :work_effort_status_type_id
      t.boolean :is_initial_status

      #better nested set columns
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
    end
  end

  def self.down
    drop_table :work_requirement_work_effort_status_types
  end
end
