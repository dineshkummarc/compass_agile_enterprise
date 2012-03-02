module ErpCommerce
	module Extensions
		module ActiveRecord
			module ActsAsPriceable
		    def self.included(base)
          base.extend(ClassMethods)  	        	      	
        end

    		module ClassMethods
      
      		def acts_as_priceable
            extend ActsAsPriceable::SingletonMethods
    			  include ActsAsPriceable::InstanceMethods
            
            has_many  :pricing_plan_assignments, :as => :priceable_item 
            has_many  :pricing_plans, :through => :pricing_plan_assignments, :dependent => :destroy
            has_many  :prices, :as => :priced_item, :dependent => :destroy 
         										     			
    		  end
    		end
  		
    		module SingletonMethods			
    		end
				
    		module InstanceMethods 
    		  def get_default_price
    		    self.pricing_plans.first.get_price
    	    end

          def get_current_simple_amount_with_currency
            amount = nil
            plan = get_current_simple_plan
            unless plan.nil?
              amount = help.number_to_currency(plan.money_amount, :unit => plan.currency.symbol)
            end
            amount
          end

          def get_current_simple_plan
            self.pricing_plans.find(:first, 
              :conditions => ['is_simple_amount = ? and from_date <= ? and thru_date >= ?', true, Date.today, Date.today])
          end

          class Helper
            include Singleton
            include ActionView::Helpers::NumberHelper
          end

          def help
            Helper.instance
          end
		        
    	  end
      end
    end
  end
end