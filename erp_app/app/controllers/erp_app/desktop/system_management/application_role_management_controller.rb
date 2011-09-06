module ErpApp
	module Desktop
		module SystemManagement
			class ApplicationRoleManagementController < ErpApp::Desktop::BaseController
			  def applications
          apps = Application.all

          node_hashes = []
          apps.each do |app|
            if !app.widgets.nil? && !app.widgets.empty?
              children_hashes = []
              app.widgets.each do |widget|
                children_hashes << {:text => widget.description, :leaf => true, :iconCls => 'icon-document', :widget_id => widget.id}
              end
              node_hashes << {:text => app.description, :iconCls => app.icon, :leaf => false, :children => children_hashes, :app_id => app.id}
            end
          end
          
          render :json => node_hashes
			  end

			  def available_roles
          id = params[:id]
          widget = Widget.find(id)
          all_roles = Role.all
          current_role_ids = widget.roles.collect{|r| r.id}
          roles = all_roles.delete_if{|r| current_role_ids.include?(r.id)}

          render :json => roles.map{|role| {:text => role.description, :leaf => true, :iconCls => 'icon-user', :role_id => role.id}}
			  end

			  def current_roles
          id = params[:id]
          widget = Widget.find(id)
          roles = widget.roles

          render :json => roles.map{|role| {:text => role.description, :leaf => true, :iconCls => 'icon-user', :role_id => role.id}}
			  end

			  def save_roles
          id = params[:id]
          role_ids = params[:role_ids]

          widget = Widget.find(id)
          roles = Role.where("id in (#{role_ids.join(',')})")
          widget.roles = roles
          widget.save

          render :json => {:success => true, :message => 'Roles Saved'}
			  end
			  
			end
		end
	end
end