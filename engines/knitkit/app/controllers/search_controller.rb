class SearchController < BaseController
  
  def create
    options = {
      :website_id => @website.id,
      :query => params[:query],
      :content_type => params[:content_type],
      :section_permalink => params[:section_permalink],
      :page => page,
      :per_page => per_page
    }
    @results = Content.do_search(options)
    
    render :show
  end
  
  def index
    
  end
  
  def set_section
    return false
  end
end