module ErpServices::Products
	module ActsAsProductOffer

		def self.included(base)
      base.extend(ClassMethods)  	        	      	
    end

		module ClassMethods

  		def acts_as_product_offer

  			has_one :product_offer, :as => :product_offer_record 
  		    			
			  extend ErpServices::Products::ActsAsProductOffer::SingletonMethods
			  include ErpServices::Products::ActsAsProductOffer::InstanceMethods												
											     			
		  end

		end
  		
		module SingletonMethods			
		end
				
		module InstanceMethods
		  
  			def after_create			  
  			  t = ProductOffer.new
  			  t.description = self.description
			  
  			  t.save
          self.product_offer = t
          self.save	  
  			end		  

        def after_update
          self.product_offer.description = self.description
          self.product_offer.save
        end 
        
        def after_destroy
          if self.product_offer && !self.product_offer.frozen?
            self.product_offer.destroy
          end          
        end
		  
	  end
					
  end
  		
end

ActiveRecord::Base.send(:include, ErpServices::Products::ActsAsProductOffer)