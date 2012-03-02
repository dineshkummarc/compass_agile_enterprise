class AddWorkEffortToWorkEffortAssignment < ActiveRecord::Migration
  def change
    unless columns(:work_effort_assignments).collect {|c| c.name}.include?('work_effort_id')
      add_column :work_effort_assignments, :work_effort_id, :integer
      remove_column :work_effort, :work_effort_assignment_id
    end
  end
end
