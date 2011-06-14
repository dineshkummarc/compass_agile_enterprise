module ErpServices::Products
	module ActsAsProductInstance

		def self.included(base)
      base.extend(ClassMethods)  	        	      	
    end

		module ClassMethods
      
  		def acts_as_product_instance
        has_one :product_instance, :as => :product_instance_record
         			
			  [:product_type,:product_type=,:description,:description=].each do |m| delegate m, :to => :product_instance end

        extend ErpServices::Products::ActsAsProductInstance::SingletonMethods
			  include ErpServices::Products::ActsAsProductInstance::InstanceMethods												
											     			
		  end

		end
  		
		module SingletonMethods			
		end
				
		module InstanceMethods
      def after_create
        self.product_instance.save
      end

      def after_initialize
        if self.new_record? && self.product_instance.nil?
          product_instance = ProductInstance.new
          self.product_instance = product_instance
          product_instance.product_instance_record = self
        end
      end

      def after_update
        self.product_instance.save
      end
        
      def after_destroy
        if self.product_instance && !self.product_instance.frozen?
          self.product_instance.destroy
        end
      end

	  end
					
  end
  		
end

ActiveRecord::Base.send(:include, ErpServices::Products::ActsAsProductInstance)