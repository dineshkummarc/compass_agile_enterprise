module ErpServices::WorkEffort
  module ActsAsSupportEffort
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def acts_as_support_effort

        has_one :support_effort, :as => :work_effort_record
        
        [
          :facility, 
          :facility=,
          :work_effort_assignment, 
          :work_effort_statuses,
          :projected_cost,
          :actual_cost
        ].each do |m| delegate m, :to => :support_effort end
        
        extend ActsAsSupportEffort::SingletonMethods
        include ActsAsSupportEffort::InstanceMethods

      end
    end

    module SingletonMethods
    end

    module InstanceMethods
      def method_missing(name, *args)
         if self.support_effort.respond_to?(name)
           self.support_effort.send(name, *args)
         else
           super
         end
      end
      
      def after_update
        self.support_effort.save
      end

      def after_create
        self.support_effort.save
      end

      def before_destroy
        self.support_effort.destroy
      end

      def after_initialize()
        if (self.support_effort.nil?)
          support_effort = SupportEffort.new
          self.support_effort = support_effort
          support_effort.work_effort_record = self
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, ErpServices::WorkEffort::ActsAsSupportEffort)
