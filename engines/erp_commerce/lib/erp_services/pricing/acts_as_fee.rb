module ErpServices::Pricing
	module ActsAsFee

		def self.included(base)
      base.extend(ClassMethods)  	        	      	
    end

		module ClassMethods
      
  		def acts_as_fee

        has_one :fee, :as => :fee_record
        
        #from Fee
        [ :money, :money=,
          :fee_type, :fee_type=,
          :description, :description=,
          :start_date, :start_date=,
          :end_date, :end_date=,
          :external_identifier, :external_identifier=,
          :external_id_source, :external_id_source=,
          :created_at,
          :updated_at 
        ].each { |m| delegate m, :to => :fee }
         						  
        extend ErpServices::Pricing::ActsAsFee::SingletonMethods
			  include ErpServices::Pricing::ActsAsFee::InstanceMethods
											     			
		  end

		end
  		
		module SingletonMethods			
		end
				
		module InstanceMethods 
		  
      def fee
        self.fee
      end

      # called after object initilized (either via .new or after loaded from the DB)
      def after_initialize()
        #puts "after_initialize: #{self.class.name} #{self.id}"
        if self.new_record? && self.fee == nil
          #puts "after_initialize: making new Fee"
          self.fee = Fee.new
        end
      end

      # Is called after Base.save on existing objects that have a record.
      def after_update
        #puts "after_update: #{self.class.name} #{self.id}"
        #puts "saving the order #{self.order_txn.id}"
      	self.fee.save_with_validation!
      end

      # Is called after Base.destroy (and all the attributes have been frozen).
      def after_destroy
        if self.fee && !self.fee.frozen?
          self.fee.destroy
        end
      end		  
		        
	  end
					
  end
  		
end

ActiveRecord::Base.send(:include, ErpServices::Pricing::ActsAsFee)