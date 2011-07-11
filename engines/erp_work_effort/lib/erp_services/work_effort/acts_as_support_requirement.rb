module ErpServices::WorkEffort
  module ActsAsSupportRequirement
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def acts_as_support_requirement

        has_one :support_requirement, :as => :work_requirement_record

        extend ActsAsSupportRequirement::SingletonMethods
        include ActsAsSupportRequirement::InstanceMethods

      end
    end

    module SingletonMethods
    end

    module InstanceMethods
      def method_missing(name, *args)
         if self.support_requirement.respond_to?(name)
           self.support_requirement.send(name, *args)
         else
           super
         end
      end
      
      def after_update
        self.support_requirement.save
      end

      def after_create
        self.support_requirement.save
      end

      def before_destroy
        self.support_requirement.destroy
      end

      def after_initialize()
        if (self.support_requirement.nil?)
          support_requirement = SupportRequirement.new
          self.support_requirement = support_requirement
          support_requirement.work_requirement_record = self
        end
      end

    end
  end
end

ActiveRecord::Base.send(:include, ErpServices::WorkEffort::ActsAsSupportRequirement)
