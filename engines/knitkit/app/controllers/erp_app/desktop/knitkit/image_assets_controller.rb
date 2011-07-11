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
  
end
