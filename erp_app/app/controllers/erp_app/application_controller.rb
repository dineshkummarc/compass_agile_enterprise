module ErpApp
	class ApplicationController < ActionController::Base
    protect_from_forgery

    protected
    def not_authenticated
      redirect_to '/erp_app/login', :notice => "Please login first."
    end
    
	end
end
