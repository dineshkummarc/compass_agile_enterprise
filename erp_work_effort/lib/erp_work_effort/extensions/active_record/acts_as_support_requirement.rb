module ErpWorkEffort
	module Extensions
		module ActiveRecord
			module ActsAsSupportRequirement
			  
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def acts_as_support_requirement
            extend ActsAsSupportRequirement::SingletonMethods
            include ActsAsSupportRequirement::InstanceMethods
        
            after_initialize :new_support_requirement
            after_update     :save_support_requirement
            after_save       :save_support_requirement
    				after_destroy    :destroy_support_requirement
        
            has_one :support_requirement, :as => :work_requirement_record

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
            ].each do |m| delegate m, :to => :support_requirement end
        
          end
        end

        module SingletonMethods
        end

        module InstanceMethods
          def method_missing(name, *args)
             self.support_requirement.respond_to?(name) ? self.support_requirement.send(name, *args) : super
          end
          
          def save_support_requirement
            self.support_requirement.save
          end

          def destroy_support_requirement
            self.support_requirement.destroy
          end

          def new_support_requirement
            if (self.support_requirement.nil?)
              support_requirement = SupportEffort.new
              self.support_requirement = support_requirement
              support_requirement.work_requirement_record = self
            end
          end
        end
      end
    end
  end
end
