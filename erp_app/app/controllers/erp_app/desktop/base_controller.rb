module ErpApp
	module Desktop
		class BaseController < ErpApp::ApplicationController
		  layout nil
		  before_filter :authenticate_user!

		  def index
        @user     = current_user
        @desktop  = ::Desktop.find_by_user(@user)
			
        render :layout => false
		  end
		  
		end
	end
end
