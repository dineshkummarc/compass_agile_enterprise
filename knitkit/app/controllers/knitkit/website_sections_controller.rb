module Knitkit
  class WebsiteSectionsController < BaseController

    def index
      @current_user = current_user
      @contents = Article.find_published_by_section(@active_publication, @website_section)
      layout = @website_section.get_published_layout(@active_publication)
      unless layout.nil?
        @website_section.render_base_layout? ? (render :inline => layout, :layout => 'knitkit/base') : (render :inline => layout)
      else
        @website_section.render_base_layout? ? (render) : (render :layout => false)
      end
    end
    
  end
end
