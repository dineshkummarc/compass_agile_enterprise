class BaseApps::Ecommerce::ReservationsController < ApplicationController
  include TechServices::Authentication::CompassAuthentication
  layout('base_apps/ecommerce/layouts/application')
  before_filter :load_current_party_from_session
  
  before_filter "login_required(nil)"

  def index
    buckets = ErpServices::DomainServices::VacationOwnership::Ownership::OwnershipMgr.instance.get_ownership_buckets_for_party current_user.party
    if buckets.size > 0
      @reservations = buckets[0].reservations
    else
      @reservations = {:current_reservations => [], :past_reservations => []}
    end
    
  end
  
  protected

  def load_current_party_from_session
    if session[:current_party_id]
      @current_party = Party.find(session[:current_party_id])
    end
  end

  # override the 'compass_application_logon_path' defined in CompassAuthentication
  def compass_application_logon_path
    return "/ecommerce/login"
  end
end