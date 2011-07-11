class WebsiteSectionsController < BaseController
  def index
    if @website_section.has_access?(current_user)
      @contents = Article.find_published_by_section(@active_publication, @website_section)
      unless @website_section.layout.nil?
        layout = @website_section.get_published_layout(@active_publication)
        render :inline => layout, :layout => 'base'
      end
    else
      redirect_to '/unauthorized'
    end
  end
end
