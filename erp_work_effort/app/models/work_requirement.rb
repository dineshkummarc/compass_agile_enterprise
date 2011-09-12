class WorkRequirement < ActiveRecord::Base
  acts_as_nested_set

  belongs_to  :work_requirement_record, :polymorphic => true
  belongs_to  :facility, :polymorphic => true
  has_many    :valid_work_assignments
  has_many    :work_requirement_work_effort_status_types, :dependent => :destroy
  has_many    :work_effort_status_types, :through => :work_requirement_work_effort_status_types
  belongs_to  :projected_cost, :class_name => "Cost", :foreign_key => 'cost_id'
  
  def set_status_type_as_initial_status(status_type)
    changing_status_type = self.work_effort_status_types.find_by_internal_identifier(status_type.internal_identifier)
    unless changing_status_type.nil?
      clear_initial_status_type
      changed_status_type = self.work_requirement_work_effort_status_types.find(:first, :conditions => ["work_effort_status_type_id = ?", changing_status_type.id])
      changed_status_type.is_initial_status = true
      changed_status_type.save
    else
      raise "Work Requirement Does Not Contain Work Effort Status Type"
    end
  end

  def add_status_type(status_type, is_initial_status=false)
    status_rel = WorkRequirementWorkEffortStatusType.new
    status_rel.work_effort_status_type = status_type
    if is_initial_status
      clear_initial_status_type
      status_rel.is_initial_status = is_initial_status
    end
    status_rel.work_requirement = self
    status_rel.save
  end

  def initial_work_effort_status_type
    status_rel = get_initial_status_type
    status_rel.nil? ? (raise "No Initial Status Set For Requirement") : status_rel.work_effort_status_type
  end

  def create_work_efforts(effort_class, initial_status_type=nil)
    parent_effort = create_effort(effort_class, self)
    self.children.each{ |req_child|
      child_effort = create_effort(effort_class, req_child)
      child_effort.work_effort.move_to_child_of(parent_effort.work_effort)
      child_effort.save!
    }

    initial_status_type.nil? ? parent_effort.start(initial_work_effort_status_type) : parent_effort.start(initial_status_type)
    parent_effort
  end

  protected
  def create_effort(effort_class, req)
    effort = effort_class.new

    effort.description = req.description
    effort.projected_completion_time = req.projected_completion_time
    effort.projected_cost = req.projected_cost
    effort.facility = req.facility
    effort.save!
    
    effort
  end

  def clear_initial_status_type
    initial_status_type = get_initial_status_type
    unless initial_status_type.nil?
      initial_status_type.is_initial_status = false
      initial_status_type.save
    end
  end

  def get_initial_status_type
    work_requirement_work_effort_status_types.where('is_initial_status = 1').first
  end
end
