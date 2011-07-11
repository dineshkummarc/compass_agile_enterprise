module ErpServices::Inventory
	module ActsAsInventoryEntry

		def self.included(base)
      base.extend(ClassMethods)  	        	      	
    end

		module ClassMethods

  		def acts_as_inventory_entry
  		  
        has_one :inventory_entry, :as => :inventory_entry_record  		

        [
          :product_type,:product_type=,
          :product_instances,
          :number_available,:number_available=
        ].each do |m|
          delegate m, :to => :inventory_entry
        end

			  extend ErpServices::Inventory::ActsAsInventoryEntry::SingletonMethods
			  include ErpServices::Inventory::ActsAsInventoryEntry::InstanceMethods												
											     			
		  end

		end
  		
		module SingletonMethods			
		end
				
		module InstanceMethods
		  def after_initialize()
        if self.new_record? && self.inventory_entry == nil
          self.inventory_entry = InventoryEntry.new
          self.inventory_entry.inventory_entry_record = self
        end
      end

      def after_update
        self.inventory_entry.save
      end 
    
      def after_destroy
        if self.inventory_entry && !self.inventory_entry.frozen?
          self.inventory_entry.destroy
        end          
      end		  
		  
	  end
					
  end
  		
end

ActiveRecord::Base.send(:include, ErpServices::Inventory::ActsAsInventoryEntry)