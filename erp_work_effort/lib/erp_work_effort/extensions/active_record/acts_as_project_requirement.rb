module ErpWorkEffort
	module Extensions
		module ActiveRecord
			module ActsAsProjectRequirement
			  
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def acts_as_project_requirement
            extend ActsAsProjectRequirement::SingletonMethods
            include ActsAsProjectRequirement::InstanceMethods
        
            after_initialize :new_project_requirement
            after_update     :save_project_requirement
            after_save       :save_project_requirement
    				after_destroy    :destroy_project_requirement
        
            has_one :project_requirement, :as => :work_requirement_record
        
            [
              :description,
              :description=,
              :facility,
              :facility=,
              :valid_work_assignments,
              :work_requirement_work_effort_status_types,
              :work_effort_status_types,
              :projected_cost=,
              :projected_cost,
              :projected_completion_time,
              :projected_completion_time=,
              :add_status_type,
              :add_status_type=
            ].each do |m| delegate m, :to => :project_requirement end
        
          end
        end

        module SingletonMethods
        end

        module InstanceMethods
          def save_project_requirement
            self.project_requirement.save
          end

          def destroy_project_requirement
            self.project_requirement.destroy
          end

          def new_project_requirement
            if (self.project_requirement.nil?)
              project_requirement = ProjectRequirement.new
              self.project_requirement = project_requirement
              project_requirement.work_requirement_record = self
            end
          end
        end
      end
    end
  end
end