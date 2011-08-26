module HasDynamicForms

		def self.included(base)
      base.extend(ClassMethods)  	        	      	
    end

		module ClassMethods

  		def has_dynamic_forms
  		  
  		  attr_accessor :dynamic_form
  		  
			  extend HasDynamicForms::SingletonMethods
			  include HasDynamicForms::InstanceMethods			
			  
        def set_default(form_id)
          DynamicForm.update_all({ :default => false }, conditions={ :model_name => self.class_name.to_s })
          DynamicForm.update_all({ :default => true }, conditions={ :id => form_id })
        end			  								     			
		  end

		end
  		
		module SingletonMethods
						
		end
				
		module InstanceMethods

      def new_form
        d = DynamicForm.new
        d.model_name = self.class.to_s
        d.dynamic_form_model_id = self.dynamic_form_model_id
        return self.dynamic_form = d        
      end

      def form
        unless self.dynamic_form.nil?
          return self.dynamic_form
        else
          current_form = default_form
          unless current_form.nil?
            return current_form
          else
            return new_form
          end
        end
      end

      def default_form        
        get_form
      end

      # get active form by type and active columns
			def get_form(internal_identifier='')
			  self.dynamic_form = DynamicForm.get_form(self.class.to_s, internal_identifier)
			end

      # get all forms by type
      def forms
			  DynamicForm.find_all_by_model_name(self.class_name)
      end

		end	
end

ActiveRecord::Base.send(:include, HasDynamicForms)
