class ErpApp::ApplicationController < ActionController::Base
  # AuthenticatedSystem must be included for RoleRequirement, and is provided by installing
  # acts_as_authenticates and running 'script/generate authenticated account user'.
  include TechServices::Authentication::AuthenticatedSystem
  # You can move this into a different controller, if you wish.
  # This module gives you the require_role helpers, and others.
  include TechServices::Authentication::RoleRequirementSystem

  def create
    session[:logout_to] = params[:logout_to] unless params[:logout_to].blank?
    id = cookies[:remember_me_id]
    unless id.blank?
      u = User.find(id)
      unless u.nil?
        @login = u.login
      else
        @login = ""
      end
    end

    result = password_authentication(params[:login], params[:password])

    if result
      render :inline => '{success:true}'
    else
      render :inline => '{success:false}'
    end
  end

  def destroy
    landing_page=session[:logout_to] # this will retrieve the appropriate landing page
    logout_keeping_session!
    flash[:notice] = "You have been logged out."
    #redirect_to home_path
    if(landing_page.blank?)
      redirect_to "/"
    else
      redirect_to landing_page # take the user to the root app TODO should this be the default behavior?
    end
  end

  #Authentication Stuff
  protected
  
  def login_path
    return ''
  end

  def password_authentication(name, password)
    puts name, password
    user = User.authenticate(name, password)
    if user
      successful_login(user)
      return true
    else
      failed_login()
      return false
    end
  end


  def successful_login(user)
    refered_from = session[:refered_from]
    return_to    = session[:return_to]
    logout_to    = session[:logout_to]

    session[:refered_from] = refered_from
    session[:return_to]    = return_to
    session[:logout_to]    = logout_to
    self.current_user      = user
    remember_user_flag     = params[:remember_me]

    if remember_user_flag
      cookies[:remember_me_id]= { :value => user.id, :expires => 30.days.from_now }
    else
      cookies[:remember_me_id]= nil
    end

    #set the current party id to be the party id of the user who just
    #logged in
    session[:current_party_id] = user.party_id
    session[:user_name]="#{user.login}"
  end

  def failed_login()
    @login = params[:login]
    @remember_me = params[:remember_me]
    @bad_visitor ||= UserFailure.failure_check(request.remote_ip)
  end
end
