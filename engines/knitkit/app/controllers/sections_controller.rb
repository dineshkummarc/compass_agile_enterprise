class SectionsController < BaseController
  def index
    @contents = Article.find_published_by_site_section(@site, @section)
    unless @section.layout.nil?
      render_section_layout
    end
  end

  protected
  
  def render_section_layout
    render :action => "#{@section.title.underscore}_#{@section.id}"
  end
end
