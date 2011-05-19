class SearchController < BaseController
  
  def create
    @results = Content.do_search(params[:query])
    
    render :show
  end
  
  def index
    
  end
  
  def set_section
    return false
  end
end