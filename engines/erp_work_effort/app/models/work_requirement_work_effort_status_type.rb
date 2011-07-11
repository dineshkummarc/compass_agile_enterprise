class WorkRequirementWorkEffortStatusType < ActiveRecord::Base
  belongs_to :work_requirement, :foreign_key => 'work_requirement_id'
  belongs_to :work_effort_status_type, :foreign_key => 'work_effort_status_type_id'
end
