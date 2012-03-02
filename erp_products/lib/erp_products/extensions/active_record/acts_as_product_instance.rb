module ErpProducts
	module Extensions
		module ActiveRecord
			module ActsAsProductInstance
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def acts_as_product_instance
            extend ActsAsProductInstance::SingletonMethods
            include ActsAsProductInstance::InstanceMethods

            after_initialize :initialize_product_instance
            after_create :save_product_instance
            after_update :save_product_instance
            after_destroy :destroy_product_instance

            has_one :product_instance, :as => :product_instance_record

            [:product_type,:product_type=,:description,:description=].each do |m| delegate m, :to => :product_instance end

          end
        end

        module SingletonMethods
        end

        module InstanceMethods
          def save_product_instance
            self.product_instance.save
          end

          def initialize_product_instance
            if self.new_record? && self.product_instance.nil?
              product_instance = ProductInstance.new
              self.product_instance = product_instance
              product_instance.product_instance_record = self
            end
          end

          def destroy_product_instance
              self.product_instance.destroy if (self.product_instance && !self.product_instance.frozen?)
          end

        end
      end
    end
  end
end