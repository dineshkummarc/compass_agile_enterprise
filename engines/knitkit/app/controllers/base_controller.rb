class BaseController < ErpApp::ApplicationController
  before_filter :set_website
  before_filter :set_active_publication, :load_sections, :set_section, :except => [:view_current_publication]
  acts_as_themed_controller :current_themes => lambda {|c| c.website.themes.active if c.website }

  def website
    @website
  end

  def view_current_publication
    session[:site_version].delete_if{|item| item[:site_id] == @site.id}
    redirect_to request.env["HTTP_REFERER"]
  end
  
  protected
  def set_website
    @website = Website.find_by_host!(request.host_with_port) # or raise "can not set website from host #{request.host_with_port}"
  end
    
  def load_sections
    @website_sections = @website.website_sections
  end
    
  def set_section
    unless params[:section_id].nil?
      @website_section = WebsiteSection.find(params[:section_id])
    else
      raise "No Id set"
    end
  end

  def set_active_publication
    @active_publication = @website.active_publication
    if !session[:website_version].blank? && !session[:website_version].empty?
      site_version_hash = session[:website_version].find{|item| item[:website_id] == @website.id}
      unless site_version_hash.nil?
        @active_publication = @website.published_websites.find(:first, :conditions => ['version = ?', site_version_hash[:version].to_f])
      end
    end
  end
end
