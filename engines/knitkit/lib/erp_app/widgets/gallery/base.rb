class ErpApp::Widgets::Gallery::Base < ErpApp::Widgets::Base

  def self.title
    "Gallery"
  end

  def index
    # @website = Website.find_by_host(request.host_with_port)
    # logger.info { "*********************************************Inside gallery base.rb, @website: #{@website.id}" }
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
