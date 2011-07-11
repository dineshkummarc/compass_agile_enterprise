module ErpServices::Products
	module ActsAsProductPackage

		def self.included(base)
      base.extend(ClassMethods)  	        	      	
    end

		module ClassMethods
      
  		def acts_as_product_package
        has_one :product_package, :as => :product_package_record
         			
			  [:product_type,:product_type=, :description, :description= ].each do |m|
			    delegate m, :to => :product_instance
			  end
			  
        extend ErpServices::Products::ActsAsProductPackage::SingletonMethods
			  include ErpServices::Products::ActsAsProductPackage::InstanceMethods
											     			
		  end

		end
  		
		module SingletonMethods			
		end
				
		module InstanceMethods 
      def after_create
  			    			  
        t = ProductInstancePool.new
        #PROBLEM#
        #t.description = self.description
			  
        t.save
        self.product_instance_pool = t
        self.save
      end

      def after_update
        #PROBLEM#
        #self.product_instance_pool.description = self.description
        self.product_instance_pool.save
      end
        
      def after_destroy
        if self.product_instance_pool && !self.product_instance_pool.frozen?
          self.product_instance_pool.destroy
        end
      end
      
      
	  end
					
  end
  		
end

ActiveRecord::Base.send(:include, ErpServices::Products::ActsAsProductPackage)