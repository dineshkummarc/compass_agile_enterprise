module ErpApp
	module Desktop
		module UserManagement
			class ApplicationManagementController < ErpApp::Desktop::UserManagement::BaseController
			  
			  def available_applications
          user_id            = params[:user_id]
          app_container_type = params[:app_container_type]

          if app_container_type == 'Desktop'
            app_container = ::Desktop.find_by_user(User.find(user_id))
            applications = DesktopApplication.all
          else
            app_container = ::Organizer.find_by_user(User.find(user_id))
            applications = OrganizerApplication.all
          end
          current_applications = app_container.applications
          applications.delete_if{|r| current_applications.collect(&:id).include?(r.id)}

          render :json => applications.map{|application| {:text => application.description, :app_id => application.id, :iconCls => application.icon, :leaf => true}}
			  end

			  def current_applications
          user_id            = params[:user_id]
          app_container_type = params[:app_container_type]

          user = User.find(user_id)
          app_container = (app_container_type == 'Desktop') ? user.desktop : user.organizer
          render :json => app_container.applications.map{|application| {:text => application.description, :app_id => application.id, :iconCls => application.icon, :leaf => true}}
			  end

			  def save_applications
          app_ids            = params[:app_ids]
          user_id            = params[:user_id]
          app_container_type = params[:app_container_type]

          user = User.find(user_id)
          app_container = (app_container_type == 'Desktop') ? user.desktop : user.organizer
          app_container.applications = []
          app_container.save

          app_ids.each do |app_id|
            app_container.applications << Application.find(app_id)
          end
          app_container.save
				
          render :json => {:success => true, :message => 'Application(s) Saved'}
			  end
			  
			end
		end
	end
end
