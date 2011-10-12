class ErpApp::Widgets::Gallery::Base < ErpApp::Widgets::Base

  def index
    @website = Website.find_by_host(request.host_with_port)
    @images = @website.files
    @showCredits = params[:showCredits]
    @align = params[:align]
    render
  end
  
  #if module lives outside of erp_app plugin this needs to be overriden
  #get location of this class that is being executed
  def locate
    File.dirname(__FILE__)
  end
  
  class << self
    def title
      "Gallery"
    end

    def name
      File.dirname(__FILE__).split('/')[-1]
    end
  end
end
