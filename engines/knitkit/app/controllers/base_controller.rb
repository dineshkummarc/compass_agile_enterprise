class BaseController < ActionController::Base
  before_filter :set_site, :load_sections, :set_section
  acts_as_themed_controller :current_themes => lambda {|c| c.site.themes.active if c.site }

  def site
    @site
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
end
