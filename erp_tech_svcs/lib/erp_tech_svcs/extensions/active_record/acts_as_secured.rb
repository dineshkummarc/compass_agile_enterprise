module ErpTechSvcs
	module Extensions
		module ActiveRecord
			module ActsAsSecured

				def self.included(base)
					base.extend(ClassMethods)  	        	      	
				end

				module ClassMethods

				  def has_security	
				    extend ActsAsSecured::SingletonMethods
    				include ActsAsSecured::InstanceMethods			
    				
    				after_initialize :initialize_secured_model
    				after_update     :save_secured_model
    				after_create     :save_secured_model
    				after_destroy    :destroy_secured_model
    				
    				has_one :secured_model, :as => :secured_record    												
				  end
				end
				
				module SingletonMethods			
				end
						
				module InstanceMethods
				  def has_access?(user)
					  has_access = true
  					unless self.secured_model.roles.empty?
  					  has_access = if user.nil?
  						  false
  					  else
  					    user.contains_roles?(self.secured_model.roles.collect{|item| item.internal_identifier})
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
				  
				  def initialize_secured_model
            if self.new_record? && self.secured_model.nil?
              secured_model = SecuredModel.new
              self.secured_model = secured_model
              secured_model.secured_record = self
            end
          end

				  def save_secured_model
  					secured_model.save
				  end
				  
				  def destroy_secured_model
					  if self.secured_model && !self.secured_model.frozen?
  					  self.secured_model.destroy
  					end
				  end
				end
			end
		end
	end
end