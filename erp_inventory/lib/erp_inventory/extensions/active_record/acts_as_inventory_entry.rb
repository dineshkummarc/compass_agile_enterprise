module ErpCommerce
	module Extensions
		module ActiveRecord
			module ActsAsInventoryEntry
		    def self.included(base)
          base.extend(ClassMethods)  	        	      	
        end

    		module ClassMethods
      		def acts_as_inventory_entry
  		      extend ActsAsInventoryEntry::SingletonMethods
    			  include ActsAsInventoryEntry::InstanceMethods
  		      
  		      after_initialize :new_inventory_entry
            after_update     :save_inventory
            after_save       :save_inventory
    				after_destroy    :destroy_inventory
  		      
            has_one :inventory_entry, :as => :inventory_entry_record  		

            [
              :product_type,:product_type=,
              :product_instances,
              :number_available,:number_available=
            ].each do |m|
              delegate m, :to => :inventory_entry
            end			     			
    		  end
    		end
  		
    		module SingletonMethods			
    		end
				
    		module InstanceMethods
    		  def new_inventory_entry()
            if self.new_record? && self.inventory_entry == nil
              self.inventory_entry = InventoryEntry.new
              self.inventory_entry.inventory_entry_record = self
            end
          end

          def save_inventory
            self.inventory_entry.save
          end 
    
          def destroy_inventory
            if self.inventory_entry && !self.inventory_entry.frozen?
              self.inventory_entry.destroy
            end          
          end		  
		  
    	  end
      end
    end
  end
end