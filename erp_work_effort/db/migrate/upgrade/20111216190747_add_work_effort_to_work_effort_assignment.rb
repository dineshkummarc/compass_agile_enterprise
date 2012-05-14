class AddWorkEffortToWorkEffortAssignment < ActiveRecord::Migration
  def change
    unless columns(:work_effort_assignments).collect {|c| c.name}.include?('work_effort_id')
      add_column :work_effort_assignments, :work_effort_id, :integer

      # migrate data
      execute "UPDATE work_effort_assignments SET work_effort_assignments.work_effort_id=work_efforts.work_effort_assignment_id 
               FROM work_effort_assignments JOIN work_efforts ON work_effort_assignments.id=work_efforts.work_effort_assignment_id"

      remove_column :work_efforts, :work_effort_assignment_id
    end
  end
end
