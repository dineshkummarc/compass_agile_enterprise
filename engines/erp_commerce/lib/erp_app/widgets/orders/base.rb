class ErpApp::Widgets::Orders::Base < ErpApp::Widgets::Base

  def self.title
    "Orders"
  end

  def index
    @orders = OrderTxn.find_by_party_role('buyer', current_user.party)

    render
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
