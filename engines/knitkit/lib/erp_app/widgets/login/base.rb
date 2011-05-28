class ErpApp::Widgets::Login::Base < ErpApp::Widgets::Base

  def self.name
    "login"
  end

  def self.title
    "Login"
  end

  def index
    @logout_to = params[:logout_to]
    @login_to  = params[:login_to]
    
    render
  end

  def new
    @login_to = params[:login_to]

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

    result = self.controller.password_authentication(params[:login], params[:password])

    if result
      render :view => :success
    else
      render :view => :error
    end
  end

  #if module lives outside of erp_app plugin this needs to be overriden
  #get location of this class that is being executed
  def locate
    File.dirname(__FILE__)
  end
end
