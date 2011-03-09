class CreateWorkEfforts < ActiveRecord::Migration
  def self.up
    create_table :work_efforts do |t|
      t.datetime :started_at
      t.datetime :finished_at
      t.timestamps

      #polymorphic columns
      t.integer  :work_effort_record_id
      t.string   :work_effort_record__type

      #foreign keys
      t.integer  :work_requirement_id
      t.integer  :work_effort_assignment_id
      
      #better nested set columns
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
    end
  end

  def self.down
    drop_table :work_efforts
  end
end
