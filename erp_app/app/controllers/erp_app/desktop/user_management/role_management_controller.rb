module ErpApp
	module Desktop
		module UserManagement
			class RoleManagementController < ErpApp::Desktop::UserManagement::BaseController

			  def available_roles
          user_id = params[:user_id]
          roles = Role.all

          unless user_id.empty?
            current_role_ids = User.find(user_id).roles.collect{|r| r.id}
            roles.delete_if{|r| current_role_ids.include?(r.id)}
          end

          render :json => roles.map{|role| {:text => role.description, :iconCls => 'icon-user', :leaf => true, :role_id => role.id}}
        end

        def current_roles
          user_id = params[:user_id]
          roles = []

          unless user_id.empty?
            roles = User.find(user_id).roles
          end

          render :json => roles.map{|role| {:text => role.description, :iconCls => 'icon-user', :leaf => true, :role_id => role.id}}
        end

			  def save_roles
          role_ids = params[:role_ids]
          user_id  = params[:user_id]

          user = User.find(user_id)
          roles = Role.where("id in (#{role_ids.join(',')})").all
          user.remove_all_roles
          user.add_roles(roles)
          user.save

          render :json => {:success => true, :message => 'Roles Saved'}
			  end
			  
			end
		end
	end
end
