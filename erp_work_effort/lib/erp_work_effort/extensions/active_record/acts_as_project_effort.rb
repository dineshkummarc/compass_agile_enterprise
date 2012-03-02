module ErpWorkEffort
	module Extensions
		module ActiveRecord
			module ActsAsProjectEffort
			  
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def acts_as_project_effort
            extend ActsAsProjectEffort::SingletonMethods
            include ActsAsProjectEffort::InstanceMethods
        
            after_initialize :new_project_effort
            after_update     :save_project_effort
            after_save       :save_project_effort
    				after_destroy    :destroy_project_effort
        
            has_one :project_effort, :as => :work_effort_record
        
            [
              :description,
              :description=,
              :facility, 
              :facility=,
              :work_effort_assignments,
              :work_effort_statuses,
              :projected_cost,
              :projected_cost=,
              :projected_completion_time,
              :projected_completion_time=,
              :actual_cost,
              :start,
              :started?,
              :completed?,
              :send_to_status
            ].each do |m| delegate m, :to => :project_effort end
        
          end
        end

        module SingletonMethods
        end

        module InstanceMethods
          def save_project_effort
            self.project_effort.save
          end

          def destroy_project_effort
            self.project_effort.destroy
          end

          def new_project_effort
            if (self.project_effort.nil?)
              project_effort = ProjectEffort.new
              self.project_effort = project_effort
              project_effort.work_effort_record = self
            end
          end
        end
      end
    end
  end
end
