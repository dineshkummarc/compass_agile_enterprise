class ErpApp::Widgets::GoogleMap::Base < ErpApp::Widgets::Base

  def self.title
    "GoogleMap"
  end

  def index
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
