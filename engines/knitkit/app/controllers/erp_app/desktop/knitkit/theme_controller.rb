class ErpApp::Desktop::Knitkit::ThemeController < ErpApp::Desktop::FileManager::BaseController
  before_filter :set_website, :only => [:new, :change_status, :available_themes]
  before_filter :set_theme, :only => [:delete, :change_status, :copy]
  IGNORED_PARAMS = %w{action controller node_id theme_data}

  def index
    if params[:node] == ROOT_NODE
      setup_tree
    else
      expand_file_directory(params[:node], :folders_only => false)
    end
  end

  def available_themes
    result = {:success => true, :themes => []}
    @website.themes.each do |theme|
      result[:themes].push << {:id => theme.id, :name => theme.name}
    end
    render :inline => result.to_json
  end

  def new
    unless params[:theme_data].blank?
      @website.themes.import(params[:theme_data], @website)
    else
      theme = Theme.create(:website => @website, :name => params[:name])
      params.each do |k,v|
        next if k.to_s == 'name' || k.to_s == 'site_id'
        theme.send(k + '=', v) unless IGNORED_PARAMS.include?(k.to_s)
      end
      theme.save
    end
   
    render :inline => {:success => true}.to_json
  end

  def delete
    @theme.destroy
    render :inline => {:success => true}.to_json
  end

  def export
    theme = Theme.find(params[:id])
    zip_path = theme.export
    send_file(zip_path.to_s, :stream => false) rescue raise "Error sending #{zip_path} file"
  ensure
    FileUtils.rm_r File.dirname(zip_path) rescue nil
  end

  def change_status
    #clear active themes
    if (params[:active] == 'true')
      @website.deactivate_themes!
    end

    if (params[:active] == 'true')
      @theme.activate!
    else
      @theme.deactivate!
    end

    render :inline => {:success => true}.to_json
  end

  ##############################################################
  #
  # Overrides from ErpApp::Desktop::FileManager::BaseController
  #
  ##############################################################

  def create_file
    path = params[:path]
    name = params[:name]

    theme = get_theme(path)
    theme.add_file(File.join(path,name), '#Empty File')

    render :inline => {:success => true}.to_json
  end

  def upload_file
    result = {}
    if request.env['HTTP_EXTRAPOSTDATA_DIRECTORY'].blank?
      upload_path = params[:directory]
    else
      upload_path = request.env['HTTP_EXTRAPOSTDATA_DIRECTORY']
    end

    unless request.env['HTTP_X_FILE_NAME'].blank?
      contents = request.raw_post
      name     = request.env['HTTP_X_FILE_NAME']
    else
      file_contents = params[:file_data]
      name = file_contents.original_path
      if file_contents.respond_to?(:read)
        contents = file_contents.read
      elsif file_contents.respond_to?(:path)
        contents = File.read(file_contents.path)
      end
    end

    theme = get_theme(upload_path)
    name = File.join(upload_path,name)

    begin
      theme.add_file(name, contents)
      result = {:success => true}
    rescue Exception=>ex
      logger.error ex.message
			logger.error ex.backtrace.join("\n")
      result = {:success => false, :error => "Error uploading #{name}"}
    end

    render :inline => result.to_json
  end

  def delete_file
    path = params[:node]
    json_str = ''

    unless File.exists? path
      json_str = "{success:false, error:'File does not exists'}"
    else
      begin
        name = File.basename(path)
        
        theme_file = get_them_file(path)
        theme_file.destroy
        json_str = "{success:true, msg:'#{name} was deleted successfully'}"
      rescue Exception=>ex
        logger.error ex.message
        logger.error ex.backtrace.join("\n")
        json_str = "{success:false, error:'Error deleting #{name}'}"
      end

    end

    render :inline => json_str
  end

  def rename_file
    result = {:success => true, :data => {:success => true}}
    path = params[:node]
    name = params[:file_name]

    unless File.exists? path
      result = {:success => false, :data => {:success => false, :error => 'File does not exists'}}
    else
      theme_file = get_them_file(path)
      theme_file.name = name
      theme_file.save
    end

    render :inline => result.to_json
  end

  private

  def get_theme(path)
    sites_index = path.index('sites')
    sites_path  = path[sites_index..path.length]
    site_name   = sites_path.split('/')[1]
    site        = Website.find(site_name.split('-')[1])

    themes_index = path.index('themes')
    path = path[themes_index..path.length]
    theme_name = path.split('/')[1]
    theme = site.themes.find_by_theme_id(theme_name)

    theme
  end

  def get_them_file(path)
    theme = get_theme(path)
    path = path.gsub!(RAILS_ROOT,'')
    theme.files.find(:first, :conditions => ['name = ? and directory = ?', ::File.basename(path), ::File.dirname(path)])
  end

  def setup_tree
    tree = []
    sites = Website.all
    sites.each do |site|
      site_hash = {
        :text => site.title,
        :browseable => true,
        :contextMenuDisabled => true,
        :iconCls => 'icon-globe',
        :id => "site_#{site.id}",
        :leaf => false,
        :children => []
      }

      #handle themes
      themes_hash = {:text => 'Themes', :contextMenuDisabled => true, :isThemeRoot => true, :siteId => site.id, :children => []}
      site.themes.each do |theme|
        theme_hash = {:text => "#{theme.name}[#{theme.theme_id}]", :handleContextMenu => true, :siteId => site.id, :isActive => (theme.active == 1), :isTheme => true, :id => theme.id, :children => []}
        if theme.active == 1
          theme_hash[:iconCls] = 'icon-add'
        else
          theme_hash[:iconCls] = 'icon-delete'
        end
        ['stylesheets', 'javascripts', 'images', 'templates'].each do |resource_folder|
          theme_hash[:children] << {:text => resource_folder, :leaf => false, :id => "#{theme.path}/#{resource_folder}"}
        end
        themes_hash[:children] << theme_hash
      end
      site_hash[:children] << themes_hash
      tree << site_hash
    end

    render :json => tree.to_json
  end

  protected

  def set_website
    @website = Website.find(params[:site_id])
  end

  def set_theme
    @theme = Theme.find(params[:id])
  end
  
end
