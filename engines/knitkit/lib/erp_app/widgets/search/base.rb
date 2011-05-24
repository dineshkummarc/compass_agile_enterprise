class ErpApp::Widgets::Search::Base < ErpApp::Widgets::Base

  def index
    @results_permalink = params[:results_permalink]

    render
  end

  def new
    @results_permalink = params[:results_permalink]
    @website = Website.find_by_host(request.host_with_port)

    options = {
      :website_id => @website.id,
      :query => params[:query],
      :content_type => params[:content_type],
      :section_permalink => params[:section_permalink],
      :page => params[:page],
      :per_page => params[:per_page]
    }
    @results = Content.do_search(options)
    
    render :view => :show
  end
  
  #if module lives outside of erp_app plugin this needs to be overriden
  #get location of this class that is being executed
  def locate
    File.dirname(__FILE__)
  end
  
end
