class CreateWorkEffortStatusTypes < ActiveRecord::Migration
  def self.up
    create_table :work_effort_status_types do |t|
      t.string  :internal_identifier
      t.string  :description
      t.integer :next_status_id
      t.integer :previous_status_id

      t.timestamps
    end
  end

  def self.down
    drop_table :work_effort_status_types
  end
end
