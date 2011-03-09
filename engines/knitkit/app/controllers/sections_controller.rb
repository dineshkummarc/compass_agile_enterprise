class SectionsController < BaseController
  def index
    if @section.has_access?(current_user)
      @contents = Article.find_published_by_section(@active_publication, @section)
      unless @section.layout.nil?
        render_section_layout
      end
    else
      redirect_to '/unauthorized'
    end
  end

  protected
  
  def render_section_layout
    render :action => "#{@section.title.underscore}_#{@section.id}"
  end
end
