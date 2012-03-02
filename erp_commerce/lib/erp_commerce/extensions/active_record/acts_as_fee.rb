module ErpCommerce
	module Extensions
		module ActiveRecord
			module ActsAsFee
		    def self.included(base)
          base.extend(ClassMethods)  	        	      	
        end

    		module ClassMethods
      		def acts_as_fee
            extend ActsAsFee::SingletonMethods
    			  include ActsAsFee::InstanceMethods
            
            after_initialize :new_fee
            after_update     :save_fee
            after_save       :save_fee
    				after_destroy    :destroy_fee
            
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
											     			
    		  end

    		end
  		
    		module SingletonMethods			
    		end
				
    		module InstanceMethods 
          def fee
            self.fee
          end

          def new_fee
            if self.new_record? && self.fee == nil
              self.fee = Fee.new
            end
          end

          def save_fee
          	self.fee.save_with_validation!
          end

          def destroy_fee
            if self.fee && !self.fee.frozen?
              self.fee.destroy
            end
          end		  
    	  end
      end
    end
  end
end