class DropWorkRequirementAssignabilityTable < ActiveRecord::Migration
  def self.up
    drop_table :work_requirement_assignabilities
  end

  def self.down
    create_table :work_requirement_assignabilities do |t|
      t.integer :party_id
      t.integer :role_type_id
      t.integer :work_requirement_id

      t.timestamps
    end
  end
end
