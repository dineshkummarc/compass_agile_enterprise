class SearchController < BaseController
  
  def create
    @results = Content.do_search(@website.id, params[:query], page, per_page)
    
    render :show
  end
  
  def index
    
  end
  
  def set_section
    return false
  end
end