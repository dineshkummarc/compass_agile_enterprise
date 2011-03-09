class CreateWorkEffortStatuses < ActiveRecord::Migration
  def self.up
    create_table :work_effort_statuses do |t|
      t.datetime :started_at
      t.datetime :finished_at
      t.integer :work_effort_id
      t.integer :work_effort_status_type_id

      t.timestamps
    end
  end

  def self.down
    drop_table :work_effort_statuses
  end
end
