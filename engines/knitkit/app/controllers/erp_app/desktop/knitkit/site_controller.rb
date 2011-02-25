class ErpApp::Desktop::Knitkit::SiteController < ErpApp::Desktop::Knitkit::BaseController
   IGNORED_PARAMS = %w{action controller id}
  
  def index
    Site.include_root_in_json = false
    render :inline => {:sites => Site.all}.to_json
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
