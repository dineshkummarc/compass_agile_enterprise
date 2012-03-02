class WorkEffortStatus < ActiveRecord::Base
  belongs_to :work_effort
  belongs_to :work_effort_status_type
end
