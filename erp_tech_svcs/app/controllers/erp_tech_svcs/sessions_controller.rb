module ErpTechSvcs
  class SessionsController < Devise::SessionsController 
    
    # Have to reimplement :recall => "failure"
    # for warden to redirect to some action that will return what I want
    def create   
      puts resource.to_yaml
      resource = warden.authenticate!(:scope => resource_name, :recall => "failure")
      # set_flash_message :notice, :signed_in 
      sign_in_and_redirect(resource_name, resource)      
    end
    
    def new
      redirect_to '/erp_app/login'
    end
    
    def destroy
      signed_in = signed_in?(resource_name)
      sign_out(resource_name)
      set_flash_message :notice, :signed_out if signed_in
      
      redirect_to session[:logout_to].blank? ? "/" : session[:logout_to]
    end

    # Example of JSON response
    def sign_in_and_redirect(resource_or_scope, resource=nil)
      session[:logout_to] = params[:logout_to]
      scope      = Devise::Mapping.find_scope!(resource_or_scope)     
      resource ||= resource_or_scope
      sign_in(scope, resource) unless warden.user(scope) == resource
      render :json => { :success => true} 
    end

    # JSON login failure message                                                            
    def failure
      render :json => {:success => false, :errors => {:reason => "Login failed. Try again"}} 
    end
    
  end
end