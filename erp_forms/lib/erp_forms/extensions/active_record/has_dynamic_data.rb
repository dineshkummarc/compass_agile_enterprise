module ErpForms
  module Extensions
    module ActiveRecord
      module HasDynamicData
      		def self.included(base)
            base.extend(ClassMethods)  	        	      	
          end

      		module ClassMethods
        		def has_dynamic_data
      		  	include ErpForms::Extensions::ActiveRecord::HasDynamicData::InstanceMethods		
      		  	
      		  	after_save       :save_dynamic_data
      		  	after_initialize :initialize_dynamic_data
      		  	
      		  	has_one :dynamic_data, :as => :reference, :class_name => 'DynamicDatum', :dependent => :destroy

               [:reference_type,:reference_type=,
                :reference_id,:reference_id=,
                :dynamic_attributes,:dynamic_attributes=,
                ].each { |m| delegate m, :to => :dynamic_data }
                								     			
      		  end
      		end
				
      		module InstanceMethods

      			def data
      			  self.dynamic_data
      			end
	
            def save_dynamic_data
            	self.dynamic_data.save
            end  

            def initialize_dynamic_data
              if self.new_record? and self.dynamic_data.nil?
                t = DynamicDatum.new
                self.dynamic_data = t
                t.reference = self
              end
        
              if self.class == DynamicFormDocument or self.class.superclass == DynamicFormDocument
                if self.dynamic_form_model_id.nil?
                  dfm = DynamicFormModel.find_by_model_name(self.class.to_s)
                  self.dynamic_form_model_id = dfm.id unless dfm.nil?
                end        
              end        
            end      
      	end	
      end
    end
  end
end
