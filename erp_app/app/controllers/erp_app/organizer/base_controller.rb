module ErpApp
	module Organizer
		class BaseController < ErpApp::ApplicationController
		  layout nil
      before_filter :require_login
		  
		  def index
        @organizer = ::Organizer.find_by_user(current_user)
        @user = current_user
		  end
		  
		  def get_preferences
        user = current_user
        organizer = ::Organizer.find_by_user(user)

        render :inline => "{\"success\":true, \"preferences\":#{organizer.preferences.to_json(:include => [:preference_type, :preference_option])}}"
		  end

		  def setup_preferences
		    user = current_user
        organizer = ::Organizer.find_by_user(user)
			
        render :inline => "{\"success\":true, \"preference_types\":#{organizer.preference_types.to_json(:include => :preference_options)}}"
		  end

		  def update_preferences
        user = current_user
        organizer = ::Organizer.find_by_user(user)

        params.each do |k,v|
          organizer.set_preference(k, v) unless (k.to_s == 'action' or k.to_s == 'controller' or k.to_s == 'authenticity_token')
        end
        organizer.save
			
        render :inline => "{\"success\":true, \"preferences\":#{organizer.preferences.to_json(:include => [:preference_type, :preference_option])}}"
		  end
		end
	end
end
