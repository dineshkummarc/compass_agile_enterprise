class CreateWorkRequirements < ActiveRecord::Migration
  def self.up
    create_table :work_requirements do |t|
      t.string :description
      t.integer :standard_effort_time
      t.timestamps

      #polymorphic columns
      t.integer :work_requirement_record_id
      t.string  :work_requirement_record_type
      t.integer :facility_id
      t.string  :facility_type

      #better nested set columns
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
    end
  end

  def self.down
    drop_table :work_requirements
  end
end
