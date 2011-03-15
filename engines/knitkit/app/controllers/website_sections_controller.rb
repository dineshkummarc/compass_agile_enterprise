class WebsiteSectionsController < BaseController
  def index
    if @website_section.has_access?(current_user)
      @contents = Article.find_published_by_section(@active_publication, @website_section)
      unless @website_section.layout.nil?
        render_section_layout
      end
    else
      redirect_to '/unauthorized'
    end
  end

  protected
  
  def render_section_layout
    render :action => "#{@website_section.title.underscore}_#{@website_section.id}"
  end
end
