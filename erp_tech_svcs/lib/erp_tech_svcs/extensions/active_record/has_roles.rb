module ErpTechSvcs
	module Extensions
		module ActiveRecord
			module HasRoles

        module Errors
          exceptions = %w[UserDoesNotHaveAccess]
          exceptions.each { |e| const_set(e, Class.new(StandardError)) }
        end

				def self.included(base)
					base.extend(ClassMethods)  	        	      	
				end

				module ClassMethods
				  def has_roles
				    extend HasRoles::SingletonMethods
    				include HasRoles::InstanceMethods
    				
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
				  def roles
					  self.secured_model.roles
				  end

          def has_access?(user)
					  has_access = true
  					unless self.secured_model.roles.empty?
  					  has_access = if user.nil?
  						  false
  					  else
  					    user.has_role?(self.secured_model.roles.collect{|item| item.internal_identifier})
  					  end
  					end
            has_access
				  end

          def with_access(user, &block)
            if has_access?(user)
              yield
            else
              raise ErpTechSvcs::Extensions::ActiveRecord::HasRoles::UserDoesNotHaveAccess
            end
          end

				  def add_role(role)
					  role = Role.find_by_internal_identifier(role) if role.is_a? String
            unless self.has_role?(role)
  					  self.secured_model.roles << role
  					  self.secured_model.save
              self.reload
  					end
				  end

          def add_roles(*roles)
            roles.flatten!
            roles = roles[0] if roles[0].is_a? Array
            roles.each do |role|
              self.add_role(role)
            end
          end

          def remove_role(role)
            role = Role.find_by_internal_identifier(role) if role.is_a? String
            self.secured_model.roles.delete(role) if has_role?(role)
				  end

          def remove_roles(*roles)
            roles.flatten!
            roles.each do |role|
              self.remove_role(role)
              self.reload
            end
				  end

          def remove_all_roles
            self.roles.delete_all
            self.reload
				  end

          def has_role?(*passed_roles)
            result = false
            passed_roles.flatten!
            passed_roles.each do |role|
              role_iid = (role.is_a?(String)) ? role : role.internal_identifier
              self.roles.each do |this_role|
                result = true if (this_role.internal_identifier == role_iid)
                break if result
              end
              break if result
            end
            result
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


