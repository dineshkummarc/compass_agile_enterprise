class ErpApp::Widgets::Login::Base < ErpApp::Widgets::Base

  def self.title
    "Login"
  end

  def index
    @logout_to  = params[:logout_to]
    @login_to   = params[:login_to]
    @signup_url = params[:signup_url]
    
    render
  end

  def login_header
    @login_url     = params[:login_url]
    @signup_url    = params[:signup_url]
    @authenticated = self.authenticated?
    if self.authenticated?
      @user = self.current_user
    end
    
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

  def self.name
    File.dirname(__FILE__).split('/')[-1]
  end

  #if module lives outside of erp_app plugin this needs to be overriden
  #get location of this class that is being executed
  def locate
    File.dirname(__FILE__)
  end
end
