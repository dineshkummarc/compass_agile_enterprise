module Knitkit
  class BaseController < ::ErpApp::ApplicationController
    before_filter :set_website, :clear_widget_params
    before_filter :set_login_path, :set_active_publication, :load_sections, :set_section, :except => [:view_current_publication]
    acts_as_themed_controller :current_themes => lambda {|c| c.website.themes.active if c.website }

    layout 'knitkit/base'

    def website
      @website
    end

    def view_current_publication
      session[:website_version].delete_if{|item| item[:website_id] == @website.id}
      redirect_to request.env["HTTP_REFERER"]
    end
  
    protected
    def set_website
      @website = Website.find_by_host(request.host_with_port)
    end
    
    def load_sections
      @website_sections = @website.website_sections.positioned
    end

    def clear_widget_params
      session[:widgets] = {}
    end
    
    def set_section
      unless params[:section_id].nil?
        @website_section = WebsiteSection.find(params[:section_id])
        if (current_user === false and !@website_section.has_access?(current_user)) and @website_section.path != @login_path
          redirect_to @login_path
        elsif !@website_section.has_access?(current_user)
          redirect_to Rails.application.config.knitkit.unauthorized_url
        end
      else
        raise "No Id set"
      end
    end

    def set_login_path
      @login_path = @website.configurations.first.get_configuration_item(ConfigurationItemType.find_by_internal_identifier('login_url')).options.first.value
    end

    def set_active_publication
      @active_publication = @website.active_publication
      if !session[:website_version].blank? && !session[:website_version].empty?
        site_version_hash = session[:website_version].find{|item| item[:website_id] == @website.id}
        unless site_version_hash.nil?
          @active_publication = @website.published_websites.where('version = ?', site_version_hash[:version].to_f).first
        end
      end
    end
  end
end
