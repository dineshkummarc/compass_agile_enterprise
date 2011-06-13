class ValidWorkAssignment < ActiveRecord::Base
  belongs_to :party
  belongs_to :work_requirement
  belongs_to :role_type
  has_many   :valid_work_assignment_attributes, :dependent => :destroy

  alias :attributes :valid_work_assignment_attributes
end
