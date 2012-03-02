module ErpApp
	module Desktop
		module ControlPanel
			class DesktopManagementController < ErpApp::ApplicationController

			  def desktop_preferences
          user = current_user
          desktop = ::Desktop.find_by_user(user)
		  
          render :inline => "{\"success\":true, \"preference_types\":#{desktop.preference_types.to_json(:include => :preference_options)}}"
			  end

			  def selected_desktop_preferences
          user = current_user
          desktop = ::Desktop.find_by_user(user)
		  
          render :inline => "{\"success\":true, \"preferences\":#{desktop.preferences.to_json(:include => [:preference_type, :preference_option])}}"
			  end

			  def update_desktop_preferences
          user = current_user
          desktop = ::Desktop.find_by_user(user)

          params.each do |k,v|
            desktop.set_preference(k, v) unless (k.to_s == 'action' or k.to_s == 'controller' or k.to_s == 'authenticity_token')
          end
          desktop.save
				
          render :inline => "{\"success\":true, \"preferences\":#{desktop.preferences.to_json(:include => [:preference_type, :preference_option])}}"
			  end

			  def add_background
          render :inline => ::Desktop.add_background(params[:description], params[:image_data]).to_json
			  end
			end
		end
	end
end
