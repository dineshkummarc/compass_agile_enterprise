module ErpWorkEffort
	module Extensions
		module ActiveRecord
			module ActsAsSupportEffort
			  
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def acts_as_support_effort
            extend ActsAsSupportEffort::SingletonMethods
            include ActsAsSupportEffort::InstanceMethods
        
            after_initialize :new_support_effort
            after_update     :save_support_effort
            after_save       :save_support_effort
    				after_destroy    :destroy_support_effort
        
            has_one :support_effort, :as => :work_effort_record

            [
              :facility, 
              :facility=,
              :work_effort_assignment, 
              :work_effort_statuses,
              :projected_cost,
              :actual_cost
            ].each do |m| delegate m, :to => :support_effort end
        
          end
        end

        module SingletonMethods
        end

        module InstanceMethods
          def method_missing(name, *args)
             self.support_effort.respond_to?(name) ? self.support_effort.send(name, *args) : super
          end
          
          def save_support_effort
            self.support_effort.save
          end

          def destroy_support_effort
            self.support_effort.destroy
          end

          def new_support_effort
            if (self.support_effort.nil?)
              support_effort = SupportEffort.new
              self.support_effort = support_effort
              support_effort.work_effort_record = self
            end
          end
        end
      end
    end
  end
end