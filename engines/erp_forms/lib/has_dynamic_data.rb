module HasDynamicData

		def self.included(base)
      base.extend(ClassMethods)  	        	      	
    end

		module ClassMethods

  		def has_dynamic_data
		  	has_one :dynamic_data, :as => :reference, :class_name => 'DynamicDatum', :dependent => :destroy

         [:reference_type,:reference_type=,
          :reference_id,:reference_id=,
          :dynamic_attributes,:dynamic_attributes=,
          ].each { |m| delegate m, :to => :dynamic_data }

			  extend HasDynamicData::SingletonMethods
			  include HasDynamicData::InstanceMethods											     			
		  end

      

		end
  		
		module SingletonMethods
						
		end
				
		module InstanceMethods

			def data
				self.dynamic_data.proxy_target
			end
	
      def after_update
      	self.dynamic_data.save
      end  

      def after_initialize
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
      
      def after_create      
        if self.dynamic_data.nil?
          t = DynamicDatum.new
          self.dynamic_data = t
          t.reference = self

          t.save
          self.save
        end        
      end

		end	
end

ActiveRecord::Base.send(:include, HasDynamicData)
