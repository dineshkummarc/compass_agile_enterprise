module ErpApp
	module Mobile
		class BaseController < ErpApp::ApplicationController
		  layout nil
		  #before_filter :require_login

		  def index
        @user     = current_user
        #@mobile  = @user.mobile

        case request.env["HTTP_USER_AGENT"]
        when /iPhone/
          @compass_logo = 'compass-logo-1-medium.png'
        when /iPad/
          @compass_logo = 'compass-logo-1.png'
        else
          @compass_logo = 'compass-logo-1-medium.png'
        end

        render :layout => false
		  end

      def applications
        render :json => {:applications => [{:title => 'User Management', :internal_identifier => 'user_management'}]}
      end

      def show_application
        @application = MobileApplication.find_by_internal_identifier(params[:application])
      end
		  
		end
	end
end
