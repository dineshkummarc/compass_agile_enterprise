class WorkEffortStatusType < ActiveRecord::Base
  has_many   :work_effort_statuses
  has_one    :previous_status_type, :class_name => 'WorkEffortStatusType', :foreign_key => 'previous_status_id'
  has_one    :next_status_type, :class_name => 'WorkEffortStatusType', :foreign_key => 'next_status_id'
  
  def status
    description
  end

  def self.iid(internal_identifier)
  	 	self.find( :first, :conditions => ['internal_identifier = ?', internal_identifier] )
  end
end
