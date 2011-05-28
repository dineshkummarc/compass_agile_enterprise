class ErpApp::Widgets::Signup::Base < ErpApp::Widgets::Base

  def self.name
    "signup"
  end

  def self.title
    "Sign Up"
  end

  def index
    render
  end

  def new
    @website = Website.find_by_host(request.host_with_port)
    @user = User.create(
      :first_name => params[:first_name],
      :last_name => params[:last_name],
      :email => params[:email],
      :login => params[:login],
      :password => params[:password],
      :password_confirmation => params[:password_confirmation]
    )
    if @user.valid?
      @user.activated_at = Time.now
      @user.roles << @website.role
      individual = Individual.create(:current_first_name => @user.first_name, :current_last_name => @user.last_name)
      @user.party = individual.party
      @user.save
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
