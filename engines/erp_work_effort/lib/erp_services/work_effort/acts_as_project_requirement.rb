module ErpServices::WorkEffort
  module ActsAsProjectRequirement
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def acts_as_project_requirement

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
        
        extend ActsAsProjectRequirement::SingletonMethods
        include ActsAsProjectRequirement::InstanceMethods
      end
    end

    module SingletonMethods
    end

    module InstanceMethods

      def after_update
        self.project_requirement.save
      end

      def after_create
        self.project_requirement.save
      end

      def before_destroy
        self.project_requirement.destroy
      end

      def after_initialize()
        if (self.project_requirement.nil?)
          project_requirement = ProjectRequirement.new
          self.project_requirement = project_requirement
          project_requirement.work_requirement_record = self
        end
      end

    end
  end
end

ActiveRecord::Base.send(:include, ErpServices::WorkEffort::ActsAsProjectRequirement)
