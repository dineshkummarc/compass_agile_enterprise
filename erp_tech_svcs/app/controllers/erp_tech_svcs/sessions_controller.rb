module ErpTechSvcs
  class SessionsController < Devise::SessionsController 
    
    # Have to reimplement :recall => "failure"
    # for warden to redirect to some action that will return what I want
    def create   
      resource = warden.authenticate!(:scope => resource_name, :recall => "failure")
      
      session[:logout_to] = params[:logout_to]
      scope      = Devise::Mapping.find_scope!(resource_name)     
      resource ||= resource_or_scope
      sign_in(scope, resource) unless warden.user(scope) == resource    
      
      (params[:login_to].blank?) ? (render :json => {:success => true}) : (redirect_to params[:login_to])
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

    # JSON login failure message                                                            
    def failure
      messsage = "Login failed. Try again"
      flash[:notice] = messsage
      (params[:login_to].blank?) ? (render :json => {:success => false, :errors => {:reason => messsage}}) : (redirect_to params[:logout_to])
    end
    
  end
end