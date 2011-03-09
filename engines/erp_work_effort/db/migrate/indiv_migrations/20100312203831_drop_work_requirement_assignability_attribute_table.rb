class DropWorkRequirementAssignabilityAttributeTable < ActiveRecord::Migration
  def self.up
    drop_table :work_requirement_assignability_attributes
  end

  def self.down
    create_table :work_requirement_assignability_attributes do |t|
      t.string  :attribute_name
      t.string  :attribute_value
      t.integer :work_requirement_assignablity_id
      t.string  :attribute_type

      t.timestamps
    end
  end
end
