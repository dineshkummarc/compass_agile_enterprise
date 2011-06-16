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
    ignored_params = IGNORED_PARAMS | %w{allow_inquiries email_inquiries host}

    result = {}
    website = Website.new
    params.each do |k,v|
      website.send(k + '=', v) unless ignored_params.include?(k.to_s)
    end
    website.auto_activate_publication = params[:auto_activate_publication] == 'yes'
    website.email_inquiries = params[:email_inquiries] == 'yes'

    # create homepage
    website_section = WebsiteSection.new
    website_section.title = "Home"
    website_section.in_menu = true
    website.website_sections << website_section
    
    # create default sections for each widget using widget layout
    # needs updated to support widgets in more than just knitkit plugin
    # but should handle the case where the base layout may not exist
    # widgets with no base layout should not be installed
    widgets = ErpApp::Widgets::Base.installed_widgets
    widgets.each do |w|
      widget_class = "ErpApp::Widgets::#{w.camelize}::Base".constantize
      #if there is no base layout ignore this widget
      next if widget_class.base_layout.nil?
      website_section = WebsiteSection.new
      website_section.title = widget_class.title
      website_section.in_menu = true unless ["Login", "Sign Up"].include?(widget_class.title)
      website_section.layout = widget_class.base_layout
      website.website_sections << website_section
    end

    if website.save
      website.hosts << WebsiteHost.create(:host => params[:host])      
      website.save

      website.publish("Publish Default Sections")
      PublishedWebsite.activate(website, 1)
      
      result[:success] = true
    else
      result[:success] = false
    end

    render :inline => result.to_json
  end

  def update
    ignored_params = IGNORED_PARAMS | %w{email_inquiries}

    params.each do |k,v|
      @website.send(k + '=', v) unless ignored_params.include?(k.to_s)
    end
    @website.auto_activate_publication = params[:auto_activate_publication] == 'yes'
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

  def add_host
    website = Website.find(params[:id])
    website_host = WebsiteHost.create(:host => params[:host])
    website.hosts << website_host
    website.save

    render :inline => {
      :success => true,
      :node => {
        :text => website_host.host,
        :websiteHostId => website_host.id,
        :host => website_host.host,
        :iconCls => 'icon-globe',
        :url => "http://#{website_host.host}",
        :isHost => true,
        :leaf => true,
        :children => []}
      }.to_json
  end

  def update_host
    website_host = WebsiteHost.find(params[:id])
    website_host.host = params[:host]
    website_host.save

    render :inline => {:success => true}.to_json
  end

  def delete_host
    WebsiteHost.destroy(params[:id])

    render :inline => {:success => true}.to_json
  end

  private

  def set_website
    @website = Website.find(params[:id])
  end
  
end
