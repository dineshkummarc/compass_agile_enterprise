class RemoveWorkRequirementFromWorkEffort < ActiveRecord::Migration
  def self.up
    remove_column :work_efforts, :work_requirement_id
  end

  def self.down
    add_column :work_efforts, :work_requirement_id, :integer
  end
end
