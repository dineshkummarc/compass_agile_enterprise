class RemoveNestedSetColsFromWorkReqWorkEffStatTypes < ActiveRecord::Migration
  def self.up
    remove_column :work_requirement_work_effort_status_types, :parent_id
    remove_column :work_requirement_work_effort_status_types, :lft
    remove_column :work_requirement_work_effort_status_types, :rgt
  end

  def self.down
    add_column :work_requirement_work_effort_status_types, :parent_id, :integer
    add_column :work_requirement_work_effort_status_types, :lft, :integer
    add_column :work_requirement_work_effort_status_types, :rgt, :integer
  end
  
end
