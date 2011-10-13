class ErpApp::Desktop::Knitkit::FileAssetsController < ErpApp::Desktop::FileManager::BaseController

  before_filter :set_file_support
  before_filter :set_asset_model, :except => [:download_file_asset]
  before_filter :login_required, :except => [:download_file_asset]
  
  def base_path
    @base_path = nil
    if @context == :website
      @base_path = File.join(@file_support.root,"/sites/site-#{@assets_model.id}", "files") unless @assets_model.nil?
    else
      @base_path = File.join(@file_support.root,"/files") unless @assets_model.nil?
    end
  end

  def expand_directory
    if @assets_model.nil?
      render :json => []
    else
      path = (params[:node] == ROOT_NODE) ? base_path : params[:node]
      render :json => @file_support.build_tree(path, :file_asset_holder => @assets_model)
    end
  end
  
  def create_file
    path = params[:path] == 'root_node' ? base_path : params[:path]
    name = params[:name]

    @assets_model.add_file('#Empty File', File.join(@file_support.root, path, name))

    render :json => {:success => true}
  end

  def sync
    result, message = @file_support.sync(base_path, @assets_model)

    render :json => {:success => result, :message => message}
  end

  def upload_file
    result = {}
    upload_path = request.env['HTTP_EXTRAPOSTDATA_DIRECTORY'].blank? ? params[:directory] : request.env['HTTP_EXTRAPOSTDATA_DIRECTORY']
    name = request.env['HTTP_X_FILE_NAME'].blank? ? params[:file_data].original_filename : request.env['HTTP_X_FILE_NAME']          
    data = request.env['HTTP_X_FILE_NAME'].blank? ? params[:file_data] : request.raw_post
    
    begin
      upload_path == 'root_node' ? @assets_model.add_file(data, File.join(@file_support.root,base_path,name)) : @assets_model.add_file(data, File.join(@file_support.root,upload_path,name))
      result = {:success => true}
    rescue Exception=>ex
      logger.error ex.message
      logger.error ex.backtrace.join("\n")
      result = {:success => false, :error => "Error uploading file."}
    end
    
    #the awesome uploader widget whats this to mime type text, leave it render :inline
    render :inline => result.to_json
  end
  
  def save_move
    result          = {}
    path            = params[:node]
    new_parent_path = params[:parent_node]
    new_parent_path = base_path if new_parent_path == ROOT_NODE

    unless File.exists? path
      result = {:success => false, :msg => 'File does not exists'}
    else
      file = @assets_model.files.find(:first, :conditions => ['name = ? and directory = ?', ::File.basename(path), ::File.dirname(path)])
      file.move(new_parent_path.gsub(Rails.root.to_s,''))
      result = {:success => true, :msg => "#{File.basename(path)} was moved to #{new_parent_path} successfully"}
    end

    render :json => result
  end

  def delete_file
    path = params[:node]
    result = {}
    begin
      name = File.basename(path)
      result, message, is_folder = @file_support.delete_file(File.join(@file_support.root,path))
      if result && !is_folder
        file = @assets_model.files.find(:first, :conditions => ['name = ? and directory = ?', ::File.basename(path), ::File.dirname(path)])
        file.destroy
      end
      result = {:success => result, :error => message}
    rescue Exception=>ex
      logger.error ex.message
      logger.error ex.backtrace.join("\n")
      result = {:success => false, :error => "Error deleting #{name}"}
    end
    render :json => result
  end

  def rename_file
    result = {:success => true, :data => {:success => true}}
    path = params[:node]
    name = params[:file_name]

    result, message = @file_support.rename_file(path, name)
    if result
      file = @assets_model.files.find(:first, :conditions => ['name = ? and directory = ?', ::File.basename(path), ::File.dirname(path)])
      file.name = name
      file.save
    end

    render :json =>  {:success => true, :message => message}
  end

  def download_file_asset
    contents, message = @file_support.get_contents(params[:path])

    send_data contents, :filename => File.basename(path)
  end
  
  protected
  
  def set_file_support
    @file_support = TechServices::FileSupport::Base.new(:storage => TechServices::FileSupport.options[:storage])
  end

  def set_asset_model
    @context = params[:context].to_sym

    if @context == :website
      #get website id this can be an xhr request or regular
      website_id = request.env['HTTP_EXTRAPOSTDATA_WEBSITE_ID'].blank? ? params[:website_id] : request.env['HTTP_EXTRAPOSTDATA_WEBSITE_ID']
      (@assets_model = website_id.blank? ? nil : Website.find(website_id))
      
      render :inline => {:success => false, :error => "No Website Selected"}.to_json if (@assets_model.nil? && params[:action] != "base_path")
    else
      @assets_model = CompassAeInstance.first
    end
  end
  
end
