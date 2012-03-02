module ErpApp
	module Desktop
		module SystemManagement
			class ApplicationRoleManagementController < ErpApp::Desktop::BaseController
			  def applications
          desktop_apps_hash = {:text => 'Desktop', :iconCls => 'icon-folder', :children => []}
          organizer_apps_hash = {:text => 'Organizer', :iconCls => 'icon-folder', :children => []}

          build_applications_hash(DesktopApplication.all, desktop_apps_hash)
          build_applications_hash(OrganizerApplication.all, organizer_apps_hash)
          
          render :json => [desktop_apps_hash, organizer_apps_hash]
			  end

			  def available_roles
          if params[:id].blank? or params[:klass].blank?
            render :json => []
          else
            id = params[:id]
            klass = params[:klass].constantize
            model = klass.find(id)
            all_roles = Role.all
            current_role_ids = model.roles.collect{|r| r.id}
            roles = all_roles.delete_if{|r| current_role_ids.include?(r.id)}

            render :json => roles.map{|role| {:text => role.description, :leaf => true, :iconCls => 'icon-user', :role_id => role.id}}
          end
			  end

			  def current_roles
          if params[:id].blank? or params[:klass].blank?
            render :json => []
          else
            id = params[:id]
            klass = params[:klass].constantize
            model = klass.find(id)

            roles = model.roles

            render :json => roles.map{|role| {:text => role.description, :leaf => true, :iconCls => 'icon-user', :role_id => role.id}}
          end
			  end

			  def save_roles
          id = params[:id]
          role_ids = params[:role_ids]

          klass = params[:klass].constantize
          model = klass.find(id)
          roles = (role_ids.nil? ? Role.where("id in (#{role_ids.join(',')})").all : [])
          model.remove_all_roles
          model.add_roles(roles)
          model.save

          render :json => {:success => true, :message => 'Roles Saved'}
			  end

        private

        def build_applications_hash(applications, parent_hash)
          applications.each do |app|
            widgets_hash = {:text => 'Widgets', :iconCls => 'icon-folder', :children => []}
            app.widgets.each do |widget|
              widgets_hash[:children] << {:text => widget.description, :iconCls => 'icon-key', :hasRoles => true, :modelId => widget.id, :klass => 'Widget', :children => build_capabilites_hash(widget)}
            end

            app_children = [build_capabilites_hash(app),widgets_hash]
            parent_hash[:children] << {:text => app.description, :iconCls => app.icon, :leaf => false, :children => app_children, :app_id => app.id}
          end
        end

        def build_capabilites_hash(model)
          capabilities_hash = {:text => 'Capabilities', :iconCls => 'icon-folder', :children => []}
          available_capability_resources = model.available_capability_resources
          available_capability_resources.each do |resource|
            capability_resource_hash = {:text => resource, :iconCls => 'icon-folder', :children => []}
            model.capabilites_by_resource(resource).each do |capability|
              capability_resource_hash[:children] << {:text => capability.type.description, :iconCls => 'icon-key', :hasRoles => true, :leaf => true, :modelId => capability.id, :klass => 'Capability'}
            end
            capabilities_hash[:children] << capability_resource_hash
          end
          capabilities_hash
        end
			  
			end
		end
	end
end