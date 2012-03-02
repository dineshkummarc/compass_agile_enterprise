module Knitkit
  class WebsiteSectionsController < BaseController

    def index
      @login_path = @website.configurations.first.get_configuration_item(ConfigurationItemType.find_by_internal_identifier('login_url')).options.first.value

      if (current_user === false and !@website_section.has_access?(current_user)) and @website_section.path != @login_path
        redirect_to @login_path
      elsif @website_section.has_access?(current_user)
        @current_user = current_user
        @contents = Article.find_published_by_section(@active_publication, @website_section)
        layout = @website_section.get_published_layout(@active_publication)
        unless layout.nil?
          @website_section.render_base_layout? ? (render :inline => layout, :layout => 'knitkit/base') : (render :inline => layout)
        else
          @website_section.render_base_layout? ? (render) : (render :layout => false)
        end
      else
        redirect_to Rails.application.config.knitkit.unauthorized_url
      end
    end

  end
end
