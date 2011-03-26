class ErpApp::Desktop::Knitkit::WebsiteController < ErpApp::Desktop::Knitkit::BaseController
  IGNORED_PARAMS = %w{action controller id}

  before_filter :set_website, :only => [:export, :website_publications, :set_viewing_version, :activate_publication, :publish, :update, :delete]
  
  def index
    Website.include_root_in_json = false
    render :inline => {:sites => Website.all}.to_json
  end

  def website_publications
    PublishedWebsite.include_root_in_json = false
    sort  = params[:sort] || 'version'
    dir   = params[:dir] || 'DESC'
    limit = params[:limit] || 9
    start = params[:start] || 0
    
    published_websites = @website.published_websites.find(:all, :order => "#{sort} #{dir}", :limit => limit, :offset => start)
    
    #set site_version. User can view different versions. Check if they are viewing another version
    site_version = @website.active_publication.version
    if !session[:website_version].blank? && !session[:website_version].empty?
      site_version_hash = session[:website_version].find{|item| item[:website_id] == @website.id}
      unless site_version_hash.nil?
        site_version = site_version_hash[:version].to_f
      end
    end

    PublishedWebsite.class_exec(site_version) do
      @@site_version = site_version
      def viewing
        self.version == @@site_version
      end
    end

    render :inline => "{\"success\":true, \"results\":#{published_websites.count}, \"totalCount\":#{@website.published_websites.count}, \"data\":#{published_websites.to_json(:only => [:comment, :id, :version, :created_at, :active],:methods => [:viewing])} }"
  end

  def activate_publication
    @website.set_publication_version(params[:version].to_f)

    render :inline => {:success => true}.to_json
  end

  def set_viewing_version
    if session[:website_version].blank?
      session[:website_version] = []
      session[:website_version] << {:website_id => @website.id, :version => params[:version]}
    else
      session[:website_version].delete_if{|item| item[:website_id] == @website.id}
      session[:website_version] << {:website_id => @website.id, :version => params[:version]}
    end

    render :inline => {:success => true}.to_json
  end

  def publish
    @website.publish(params[:comment])

    render :inline => {:success => true}.to_json
  end

  def new
    ignored_params = IGNORED_PARAMS | %w{allow_inquiries email_inquiries}

    result = {}
    website = Website.new
    params.each do |k,v|
      website.send(k + '=', v) unless ignored_params.include?(k.to_s)
    end
    website.allow_inquiries = params[:allow_inquiries] == 'yes'
    website.email_inquiries = params[:email_inquiries] == 'yes'

    if website.save
      result[:success] = true
    else
      result[:success] = false
    end

    render :inline => result.to_json
  end

  def update
    ignored_params = IGNORED_PARAMS | %w{allow_inquiries email_inquiries}

    params.each do |k,v|
      @website.send(k + '=', v) unless ignored_params.include?(k.to_s)
    end
    @website.allow_inquiries = params[:allow_inquiries] == 'yes'
    @website.email_inquiries = params[:email_inquiries] == 'yes'

    @website.save

    render :inline => {:success => true}.to_json
  end
  
 
  def delete
    @website.destroy

    render :inline => {:success => true}.to_json
  end

  def export
    zip_path = @website.export
    send_file(zip_path.to_s, :stream => false) rescue raise "Error sending #{zip_path} file"
  ensure
    FileUtils.rm_r File.dirname(zip_path) rescue nil
  end

  def import
    result, message = Website.import(params[:website_data])

    render :inline => {:success => result, :message => message}.to_json
  ensure
    FileUtils.rm_r File.dirname(zip_path) rescue nil
  end

  private

  def set_website
    @website = Website.find(params[:id])
  end
  
end
