class BaseApps::Ecommerce::HomeController < ApplicationController

  #before_filter :login_required
  include TechServices::Authentication::CompassAuthentication
  before_filter "login_required(nil)", :except=>[:login]
  
  layout('base_apps/ecommerce/layouts/application')
  
  # render the login screen for all ecommerce secured pages
  def login
    flash[:notice]="You must be logged in to access this feature."
    @suppress_login_form=true
  end

  # override the 'compass_application_logon_path' defined in CompassAuthentication
  def compass_application_logon_path
    return "/ecommerce/login"
  end

  def about
  end

end
