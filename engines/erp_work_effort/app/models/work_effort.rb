class WorkEffort < ActiveRecord::Base
  acts_as_nested_set

  belongs_to :work_effort_record, :polymorphic => true
  belongs_to :facility, :polymorphic => true
  belongs_to :work_effort_assignment
  has_many   :work_effort_statuses

  #TODO: refactor cost needs to subclassed for hca
  belongs_to :projected_cost, :class_name => 'UserApps::Hca::Cost', :foreign_key => 'projected_cost_id'
  belongs_to :actual_cost, :class_name => 'UserApps::Hca::Cost', :foreign_key => 'actual_cost_id'
  #has_one    :work_effort_deliverable


  #for rooms
  belongs_to :room,
    :class_name => "UserApps::Hca::Room",
    :foreign_key => "work_effort_record_id"

  #get current status
  def status
    status = nil

    unless self.descendants.flatten!.nil?
      work_effort_status = self.descendants.flatten!.last.get_current_status
    else
      work_effort_status = self.get_current_status
    end

    status = work_effort_status.work_effort_status_type.description

    status
  end

  # return true if this effort has been started, false otherwise
  def started?
    get_current_status.nil? ? false : true
  end
  
  # return true if this effort has been completed, false otherwise
  def completed?
    finished_at.nil? ? false : true
  end
  
  #start initial work_status
  def start(status_type)
    effort = self
    unless self.descendants.flatten!.nil?
      children = self.descendants.flatten
      effort = children.last
    end

    current_status = effort.get_current_status

    if current_status.nil?
      work_effort_status = WorkEffortStatus.create(:started_at => DateTime.now, :work_effort_status_type => status_type)
      effort.work_effort_statuses << work_effort_status
      effort.started_at = DateTime.now
      effort.save
    else
      raise 'Effort Already Started'
    end
  end

  # completes current status if current status is in progress
  # start status passed in
  # if status passed in is last status, starts parent status if status exists
  def send_to_status(status_type, complete_effort=false, complete_status=false)
    current_status = get_current_status
    
    unless current_status.nil?
      new_work_effort_status = WorkEffortStatus.new
      new_work_effort_status.started_at = DateTime.now
      if complete_status
        new_work_effort_status.finished_at = new_work_effort_status.started_at
      end
      new_work_effort_status.work_effort_status_type = status_type
      new_work_effort_status.work_effort = self
      new_work_effort_status.save
      current_status.finished_at = DateTime.now
      current_status.save
      if complete_effort
        complete_work_effort
      end
    else
      raise 'Effort Has Not Started'
    end
  end
  
  #completes current status
  #start next status if not last status
  #starts parent status if parent exists
  def send_to_next_status
    current_status = get_current_status

    unless current_status.nil?
      next_status_type = current_status.work_effort_status_type.next_status_type

      if next_status_type.nil?
        complete_work_effort
      else
        new_work_effort_status = WorkEffortStatus.new
        new_work_effort_status.started_at = DateTime.now
        new_work_effort_status.work_effort_status_type = next_status_type
        new_work_effort_status.work_effort = self
        new_work_effort_status.save
      end

      current_status.finished_at = DateTime.now
      current_status.save
    else
      raise 'Effort Has Not Started' if current_status.nil?
    end
  end

  def send_to_previous_status
    current_status = get_current_status

    unless current_status.nil?
      previous_status_type = current_status.work_effort_status_type.previous_status_type

      if previous_status_type.nil?
        raise 'Current status is initial status' if current_status.nil?
      else
        new_work_effort_status = WorkEffortStatus.new
        new_work_effort_status.started_at = DateTime.now
        new_work_effort_status.work_effort_status_type = previous_status_type
        new_work_effort_status.work_effort = self
        new_work_effort_status.save
      end

      current_status.finished_at = DateTime.now
      current_status.save
    else
      raise 'Effort Has Not Started' if current_status.nil?
    end
  end

  def complete_work_effort
    self.finished_at = DateTime.now
    self.actual_completion_time = time_diff_in_minutes(self.finished_at.to_time, self.started_at.to_time)
    self.save
    unless self.parent.nil?
      self.parent.start_effort
    end
  end

  protected
  def get_current_status
    self.work_effort_statuses.find_by_finished_at(nil)
  end

  def time_diff_in_minutes (time_one, time_two)
    diff_seconds = (time_one - time_two).round
    diff_minutes = diff_seconds / 60
    return diff_minutes
  end
end
