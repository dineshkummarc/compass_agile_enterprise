class BaseApps::Ecommerce::InventorySearchController < BaseApps::Search::InventorySearchBaseController
  include TechServices::Authentication::CompassAuthentication
  before_filter "login_required(nil)"

  
  layout('base_apps/ecommerce/layouts/search_layout')
  
  # override the 'compass_application_logon_path' defined in CompassAuthentication
  def compass_application_logon_path
    return "/ecommerce/login"
  end

  
end
