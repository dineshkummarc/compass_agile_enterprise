module ErpServices::Pricing
	module ActsAsPriceable

		def self.included(base)
      base.extend(ClassMethods)  	        	      	
    end

		module ClassMethods
      
  		def acts_as_priceable

        has_many  :pricing_plan_assignments, :as => :priceable_item     
        has_many  :pricing_plans, :through => :pricing_plan_assignments           
        has_many  :prices, :as => :priced_item
         						  
        extend ErpServices::Pricing::ActsAsPriceable::SingletonMethods
			  include ErpServices::Pricing::ActsAsPriceable::InstanceMethods												
											     			
		  end

		end
  		
		module SingletonMethods			
		end
				
		module InstanceMethods 
		  
		  def get_default_price
		    self.pricing_plans.first.get_price
	    end
		        
	  end
					
  end
  		
end

ActiveRecord::Base.send(:include, ErpServices::Pricing::ActsAsPriceable)