class ErpApp::Desktop::Knitkit::ImageAssetsController < ErpApp::Desktop::FileManager::BaseController

  IMAGE_FILE_EXTENSIONS_REGEX = /^.?[^\.]+\.(jpe?g|png|PNG|gif|tiff)$/

  def base_path
    @base_path ||= File.join(Rails.root, "/public/images/")
  end

  def expand_directory
    expand_file_directory(params[:node], :folders_only => false)
  end

  def get_images
    directory = params[:directory]
    directory = base_path if directory == ROOT_NODE
    data = {:images => []}

    Dir.entries(directory).each do |entry|
      if entry =~ IMAGE_FILE_EXTENSIONS_REGEX
        path = directory + '/' + entry
        url_path = path.gsub(base_path.to_s, '/images/')
        #url_path = url_path.gsub('/', '\/')
        short_name = entry
        if short_name.length > 16
          short_name = short_name[0..13] + '...'
        end
        data[:images] << {:name => entry, :shortName => short_name, :url => url_path}
      end
    end unless directory.blank?

    render :inline => data.to_json
  end
  
  ##############################################################
  #
  # Overrides from ErpApp::Desktop::FileManager::BaseController
  # 
  # but uses upload_file_paperclip as a temporary interim move
  # from fileutils to paperclip
  #
  ##############################################################


  def upload_file_paperclip
    result = {}
    if request.env['HTTP_EXTRAPOSTDATA_DIRECTORY'].blank?
      upload_path = params[:directory]
    else
      upload_path = request.env['HTTP_EXTRAPOSTDATA_DIRECTORY']
    end

    website = Website.find_by_host(request.env['HTTP_HOST'])
    file_contents = params[:file_data]
    name = File.join(upload_path,file_contents.original_path)

    begin
      website.add_file(name, file_contents)
      result = {:success => true}
    rescue Exception=>ex
      logger.error ex.message
			logger.error ex.backtrace.join("\n")
      result = {:success => false, :error => "Error uploading #{name}"}
    end

    render :inline => result.to_json
  end
    
end
