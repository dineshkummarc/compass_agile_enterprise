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

				render :inline => build_ext_tree(applications_to_node_hashes(applications))
			  end

			  def current_applications
				user_id            = params[:user_id]
				app_container_type = params[:app_container_type]

				if app_container_type == 'Desktop'
				  app_container = ::Desktop.find_by_user(User.find(user_id))
				else
				  app_container = ::Organizer.find_by_user(User.find(user_id))
				end

				render :inline => build_ext_tree(applications_to_node_hashes(app_container.applications))
			  end

			  def save_applications
				app_ids            = params[:app_ids]
				user_id            = params[:user_id]
				app_container_type = params[:app_container_type]

				if app_container_type == 'Desktop'
				  app_container = ::Desktop.find_by_user(User.find(user_id))
				else
				  app_container = ::Organizer.find_by_user(User.find(user_id))
				end

				app_container.applications = []
				app_container.save

				app_ids.each do |app_id|
				  app_container.applications << Application.find(app_id)
				end
				app_container.save
				
				render :inline => "{success:true,message:'Application(s) Saved'}"
			  end

			  private

			  def applications_to_node_hashes(applications)
				node_hashes = []
				applications.each do |application|
				  node_hashes << {:text => application.description, :attributes => {:app_id => application.id}, :icon_cls => application.icon, :is_leaf => true}
				end

				node_hashes
			  end
			end
		end
	end
end
