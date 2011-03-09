class CreateWorkRequirementAssignabilities < ActiveRecord::Migration
  def self.up
    create_table :work_requirement_assignabilities do |t|
      t.integer :party_id
      t.integer :role_type_id
      t.integer :work_requirement_id

      t.timestamps
    end
  end

  def self.down
    drop_table :work_requirement_assignabilities
  end
end
