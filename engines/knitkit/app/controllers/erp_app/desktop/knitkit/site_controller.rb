class ErpApp::Desktop::Knitkit::SiteController < ErpApp::Desktop::Knitkit::BaseController
  IGNORED_PARAMS = %w{action controller id}

  before_filter :set_site, :only => [:set_viewing_version, :activate_publication, :publish, :update, :delete]
  
  def index
    Site.include_root_in_json = false
    render :inline => {:sites => Site.all}.to_json
  end

  def site_publications
    PublishedSite.include_root_in_json = false
    sort  = params[:sort] || 'version'
    dir   = params[:dir] || 'DESC'
    limit = params[:limit] || 9
    start = params[:start] || 0
    
    site = Site.find(params[:site_id])
    published_sites = site.published_sites.find(:all, :order => "#{sort} #{dir}", :limit => limit, :offset => start)
    
    #set site_version. User can view different versions. Check if they are viewing another version
    site_version = site.active_publication.version
    if !session[:site_version].blank? && !session[:site_version].empty?
      site_version_hash = session[:site_version].find{|item| item[:site_id] == site.id}
      unless site_version_hash.nil?
        site_version = site_version_hash[:version].to_f
      end
    end

    PublishedSite.class_exec(site_version) do
      @@site_version = site_version
      def viewing
        self.version == @@site_version
      end
    end

    render :inline => "{\"success\":true, \"results\":#{published_sites.count}, \"totalCount\":#{site.published_sites.count}, \"data\":#{published_sites.to_json(:only => [:comment, :id, :version, :created_at, :active],:methods => [:viewing])} }"
  end

  def activate_publication
    @site.set_publication_version(params[:version].to_f)

    render :inline => {:success => true}.to_json
  end

  def set_viewing_version
    if session[:site_version].blank?
      session[:site_version] = []
      session[:site_version] << {:site_id => @site.id, :version => params[:version]}
    else
      session[:site_version].delete_if{|item| item[:site_id] == @site.id}
      session[:site_version] << {:site_id => @site.id, :version => params[:version]}
    end

    render :inline => {:success => true}.to_json
  end

  def publish
    @site.publish(params[:comment])

    render :inline => {:success => true}.to_json
  end

  def new
    result = {}
    site = Site.new
    params.each do |k,v|
      site.send(k + '=', v) unless IGNORED_PARAMS.include?(k.to_s)
    end

    if site.save
      result[:success] = true
    else
      result[:success] = false
    end

    render :inline => result.to_json
  end

  def update
    params.each do |k,v|
      @site.send(k + '=', v) unless IGNORED_PARAMS.include?(k.to_s)
    end
    @site.save

    render :inline => {:success => true}.to_json
  end
  
 
  def delete
    @site.destroy

    render :inline => {:success => true}.to_json
  end

  private

  def set_site
    @site = Site.find(params[:id])
  end
  
end
