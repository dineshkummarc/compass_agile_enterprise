class ErpApp::Desktop::Knitkit::SiteController < ErpApp::Desktop::Knitkit::BaseController
  IGNORED_PARAMS = %w{action controller id}
  
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

    render :inline => {:success => true, :results => published_sites.count, :totalCount => site.published_sites.count, :data => published_sites}.to_json
  end

  def activate_publication
    Site.find(params[:site_id]).set_publication_version(params[:version].to_f)

    render :inline => {:success => true}.to_json
  end

  def publish
    Site.find(params[:site_id]).publish(params[:comment])

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
    site = Site.find(params[:id])
    params.each do |k,v|
      site.send(k + '=', v) unless IGNORED_PARAMS.include?(k.to_s)
    end
    site.save

    render :inline => {:success => true}.to_json
  end
  
 
  def delete
  end
  
end
