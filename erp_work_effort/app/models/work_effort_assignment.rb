class WorkEffortAssignment < ActiveRecord::Base
  belongs_to :work_effort
  belongs_to :assigned_to, :polymorphic => true
  belongs_to :assigned_by, :polymorphic => true

  validates :assigned_to, :presence => {:message => 'Assigned to cannot be blank'}
  validates :work_effort, :presence => {:message => 'Work effort cannot be blank'}
  validates :assigned_by, :presence => {:message => 'Assinged by cannot be blank'}
  
end
