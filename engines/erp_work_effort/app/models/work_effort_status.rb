class WorkEffortStatus < ActiveRecord::Base
  belongs_to :work_effort, :dependent => :destroy
  belongs_to :work_effort_status_type
end
