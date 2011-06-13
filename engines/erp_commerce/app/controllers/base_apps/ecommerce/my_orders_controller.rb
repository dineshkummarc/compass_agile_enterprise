class BaseApps::Ecommerce::MyOrdersController < ApplicationController
  include TechServices::Authentication::CompassAuthentication
  layout('base_apps/ecommerce/layouts/application')
  
  before_filter "login_required(nil)"
  before_filter :load_current_party_from_session  
  
  def index

    @current_party = current_user.party
    if @current_party
      @orders = OrderTxn.find( :all, :include => { :biz_txn_event => :biz_txn_party_roles }, 
        :conditions => "biz_txn_party_roles.party_id = #{@current_party.id}")
    else
      @orders = []
    end

	  list_by_party_role_template    
    
  end

  protected

  def load_current_party_from_session
    if session[:current_party_id]
      @current_party = Party.find(session[:current_party_id])
    end
  end

  def list_by_party_role_template
	  render :template => '/base_apps/ecommerce/my_orders/index'
  end
  # override the 'compass_application_logon_path' defined in CompassAuthentication
  def compass_application_logon_path
    return "/ecommerce/login"
  end

end
