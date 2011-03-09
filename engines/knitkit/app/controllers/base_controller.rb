class BaseController < ErpApp::ApplicationController
  before_filter :set_site
  before_filter :set_active_publication, :load_sections, :set_section, :except => [:view_current_publication]
  acts_as_themed_controller :current_themes => lambda {|c| c.site.themes.active if c.site }

  def site
    @site
  end

  def view_current_publication
    session[:site_version].delete_if{|item| item[:site_id] == @site.id}
    redirect_to request.env["HTTP_REFERER"]
  end
  
  protected
  def set_site
    @site = Site.find_by_host!(request.host_with_port) # or raise "can not set site from host #{request.host_with_port}"
  end
    
  def load_sections
    @sections = @site.sections
  end
    
  def set_section
    unless params[:section_id].nil?
      @section = Section.find(params[:section_id])
    else
      raise "No Id set"
    end
  end

  def set_active_publication
    @active_publication = @site.active_publication
    if !session[:site_version].blank? && !session[:site_version].empty?
      site_version_hash = session[:site_version].find{|item| item[:site_id] == @site.id}
      unless site_version_hash.nil?
        @active_publication = @site.published_sites.find(:first, :conditions => ['version = ?', site_version_hash[:version].to_f])
      end
    end
  end
end
