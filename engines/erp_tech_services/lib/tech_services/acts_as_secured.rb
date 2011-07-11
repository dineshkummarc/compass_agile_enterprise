module TechServices
	module ActsAsSecured

		def self.included(base)
      base.extend(ClassMethods)  	        	      	
    end

		module ClassMethods

  		def has_security
  		    			
  			has_one :secured_model, :as => :secured_record
  												
			  extend TechServices::ActsAsSecured::SingletonMethods
			  include TechServices::ActsAsSecured::InstanceMethods
											     			
		  end

		end
  		
		module SingletonMethods			
		end
				
		module InstanceMethods
      def has_access?(user)
        has_access = true
        unless self.secured_model.roles.empty?
          if user.nil?
            has_access = false
          else
            has_access = user.contains_roles?(self.secured_model.roles.collect{|item| item.internal_identifier})
          end
        end
        has_access
      end

      def roles
        self.secured_model.roles
      end

      def add_role(role)
        unless self.secured_model.roles.include?(role)
          self.secured_model.roles << role
          self.secured_model.save
        end
      end

      def remove_role(role)
        self.secured_model.roles.delete(role)
        self.secured_model.save
      end

      def after_create
        secured_model = SecuredModel.create
        secured_model.secured_record = self
        secured_model.save
        self.save
      end
      
      def after_destroy
        if self.secured_model && !self.secured_model.frozen?
          self.secured_model.destroy
        end
      end
		end
	end
end

ActiveRecord::Base.send(:include, TechServices::ActsAsSecured)