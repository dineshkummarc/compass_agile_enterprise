class ErpApp::Widgets::GoogleMap::Base < ErpApp::Widgets::Base

  def self.title
    "GoogleMap"
  end

  def index
    @uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(100).to_s)
    @drop_pins = params[:drop_pins]
    @zoom = params[:zoom] || 18
    @map_width = params[:map_width] || 500
    @map_height = params[:map_height] || 500
    @map_type = params[:map_type] || 'SATELLITE'

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
