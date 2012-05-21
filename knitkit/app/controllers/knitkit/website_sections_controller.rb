module Knitkit
  class WebsiteSectionsController < BaseController

    def index
      @current_user = current_user
      @contents = get_contents.dup
      layout = get_layout.dup

      unless layout.nil?
        @website_section.render_base_layout? ? (render :inline => layout, :layout => 'knitkit/base') : (render :inline => layout)
      else
        @website_section.render_base_layout? ? (render) : (render :layout => false)
      end
    end

    protected
    def get_contents
      Rails.cache.fetch("Contents_#{@website_section.path}", :expires_in => cache_expires_in) do
        Article.find_published_by_section(@active_publication, @website_section)
      end
    end

    def get_layout
      Rails.cache.fetch("Layout_#{@website_section.path}", :expires_in => cache_expires_in) do
        @website_section.get_published_layout(@active_publication)
      end
    end
   
  end
end
