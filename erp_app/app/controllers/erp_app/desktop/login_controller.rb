module ErpApp
	module Desktop
		class LoginController < ErpApp::ApplicationController
			def index
				render :layout => false
			end
		end
	end
end
