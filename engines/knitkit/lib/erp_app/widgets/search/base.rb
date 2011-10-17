class ErpApp::Widgets::Search::Base < ErpApp::Widgets::Base
  
  def self.title
    "Search"
  end
  
  def set_variables
    @results_path = params[:results_path]
    @section_unique_name = params[:section_unique_name]
    @content_type = params[:content_type]
    @per_page = params[:per_page]
    @css_class = params[:class]
    @ajax_results = @results_path.blank? ? true : false
  end

  def index
    set_variables
    render
  end

  def new
    set_variables
    @website = Website.find_by_host(request.host_with_port)

    options = {
      :website_id => @website.id,
      :query => params[:query],
      :content_type => params[:content_type],
      :section_unique_name => params[:section_unique_name],
      :page => (params[:page] || 1),
      :per_page => (params[:per_page] || 20)
    }
    @results = Content.do_search(options)

    render :view => :show
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
