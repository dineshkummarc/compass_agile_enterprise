class WorkEffortAssignment < ActiveRecord::Base
  has_one    :work_effort
  belongs_to :assigned_to, :polymorphic => true
  belongs_to :assigned_by, :polymorphic => true

  validates_presence_of :assigned_to, :work_effort, :assigned_by
  
  def before_destroy
    unless self.work_effort.nil?
      self.work_effort.work_effort_assignment_id = nil
      self.work_effort.save
    end
  end

end
