class CreateValidWorkAssignmentAttributes < ActiveRecord::Migration
  def self.up
    create_table :valid_work_assignment_attributes do |t|
      t.integer :valid_work_assignment_id
      t.string  :name
      t.string  :type
      t.string  :value

      t.timestamps
    end
  end

  def self.down
    drop_table :valid_work_assignment_attributes
  end
end
