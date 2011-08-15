module ErpApp
	module Desktop
		module ControlPanel
			class ApplicationManagementController < ErpApp::Desktop::ControlPanel::BaseController

			  def current_user_applcations
				user = current_user

				node_hashes = []
				desktop = user.desktop
				desktop.applications.each do |application|
				  node_hashes << {:text => application.description, :icon_cls => application.icon, :is_leaf => true, :id => application.id}
				end
				
				render :inline => build_ext_tree(node_hashes)
			  end

			  def setup
				PreferenceType.include_root_in_json = false
				PreferenceOption.include_root_in_json = false

				application_id = params[:id]
				ext_json = '{success:true,preference_types:'

				application = Application.find(application_id)

				preference_types = application.preference_types
				ext_json << preference_types.to_json(:methods => [:default_value], :include => :preference_options)
				ext_json << "}"
				render :inline => ext_json
			  end

			  def preferences
				application_id = params[:id]
				user = current_user

				application = Application.find(application_id)
				preferences = application.preferences(user)

				ext_json = "{success:true, preferences:#{preferences.to_json(:include => [:preference_type, :preference_option])}}"

				render :inline => ext_json
			  end

			  def update
				application_id = params[:id]
				user = current_user
				
				application = Application.find(application_id)
				params.each do |k,v|
				  application.set_user_preference(user, k, v) unless k.to_s == 'action' or k.to_s == 'controller' or k.to_s == 'id'
				end
				application.save
				preferences = application.preferences(user)
				
				ext_json = "{success:true, description:'#{application.description}', shortcutId:'#{application.shortcut_id}', shortcut:'#{application.get_user_preference(user, :desktop_shortcut)}', preferences:#{preferences.to_json(:include => [:preference_type, :preference_option])}}"

				render :inline => ext_json
			  end

			  def all_users_applcations
				user_id = params[:id]

				user = User.find(user_id)

				entity_info = nil
				if user.party.business_party.is_a?(Individual)
				  entity_info = user.party.business_party.to_json(:only => [:current_first_name, :current_last_name, :gender, :total_years_work_experience])
				else
				  entity_info = user.party.business_party.to_json(:only => [:description])
				end

				json_text = "{entityType:'#{user.party.business_party.class.to_s}', entityInfo:#{entity_info}}"

				render :inline => json_text
			  end
			end
		end
	end
end
