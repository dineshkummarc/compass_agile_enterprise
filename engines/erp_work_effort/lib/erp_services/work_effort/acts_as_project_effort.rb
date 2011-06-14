module ErpServices::WorkEffort
  module ActsAsProjectEffort
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def acts_as_project_effort

        has_one :project_effort, :as => :work_effort_record
        
        [
          :description,
          :description=,
          :facility, 
          :facility=,
          :work_effort_assignment, 
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
        
        extend ActsAsProjectEffort::SingletonMethods
        include ActsAsProjectEffort::InstanceMethods

      end
    end

    module SingletonMethods
    end

    module InstanceMethods
      def after_update
        self.project_effort.save
      end

      def after_create
        self.project_effort.save
      end

      def before_destroy
        self.project_effort.destroy
      end

      def after_initialize()
        if (self.project_effort.nil?)
          project_effort = ProjectEffort.new
          self.project_effort = project_effort
          project_effort.work_effort_record = self
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, ErpServices::WorkEffort::ActsAsProjectEffort)
