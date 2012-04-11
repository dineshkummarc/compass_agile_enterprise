module ErpApp
	module Mobile
		class BaseController < ErpApp::ApplicationController
		  layout nil
		  before_filter :require_login

		  def index
        @user   = current_user
        @mobile = @user.mobile

        render :layout => false
		  end

      protected
      def not_authenticated
        redirect_to '/erp_app/mobile/login', :notice => "Please login first."
      end
		  
		end
	end
end
