module ErpApp
	module Desktop
		module ControlPanel
			class ApplicationManagementController < ErpApp::Desktop::ControlPanel::BaseController

			  def current_user_applcations
          user = current_user

          node_hashes = []
          desktop = user.desktop
          desktop.applications.each do |application|
            node_hashes << {:text => application.description, :iconCls => application.icon, :leaf => true, :id => application.id}
          end

          render :json => node_hashes
			  end

			  def setup
          #remove when has_many_polymorphic is fixed
          PreferenceType

          application_id = params[:id]
          application = Application.find(application_id)

          render :inline => "{\"success\":true, \"preference_types\":#{application.preference_types.to_json(:methods => [:default_value], :include => :preference_options)}}"
			  end

			  def preferences
          application_id = params[:id]
          user = current_user
          application = Application.find(application_id)

          render :inline => "{\"success\":true, \"preferences\":#{application.preferences(user).to_json(:include => [:preference_type, :preference_option])}}"
			  end

			  def update
          application_id = params[:id]
          user = current_user

          application = Application.find(application_id)
          params.each do |k,v|
            application.set_user_preference(user, k, v) unless k.to_s == 'action' or k.to_s == 'controller' or k.to_s == 'id'
          end
          application.save

          render :inline => "{\"success\":true, \"description\":'#{application.description}', \"shortcutId\":'#{application.shortcut_id}', \"shortcut\":'#{application.get_user_preference(user, :desktop_shortcut)}', \"preferences\":#{application.preferences(user).to_json(:include => [:preference_type, :preference_option])}}"
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

          render :inline => "{\"entityType\":\"#{user.party.business_party.class.to_s}\", \"entityInfo\":#{entity_info}}"
			  end
			end
		end
	end
end