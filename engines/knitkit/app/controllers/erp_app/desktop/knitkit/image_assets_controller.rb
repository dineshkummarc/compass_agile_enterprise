class ErpApp::Desktop::Knitkit::ImageAssetsController < ErpApp::Desktop::FileManager::BaseController

  IMAGE_FILE_EXENTIONS_REGEX = /^.?[^\.]+\.(jpe?g|png|gif|tiff)$/

  def initialize
    @base_path = File.join(Rails.root, '/vendor/plugins/erp_app/public/images/')
  end

  def expand_directory
    expand_file_directory(params[:node], :folders_only => false)
  end

  def get_images
    directory = params[:directory]
    data = {:images => []}

    Dir.entries(directory).each do |entry|
      if entry =~ IMAGE_FILE_EXENTIONS_REGEX
        path = directory + '/' + entry
        url_path = path.gsub(@base_path.to_s, '/images/')
        #url_path = url_path.gsub('/', '\/')
        data[:images] << {:name => entry, :size => 2555, :lastmod => 1291155496000, :url => url_path}
      end
    end unless directory.blank?

    render :inline => data.to_json
  end

  def upload_file
    if request.env['HTTP_EXTRAPOSTDATA_DIRECTORY'].blank?
      upload_path = params[:directory]
    else
      upload_path = request.env['HTTP_EXTRAPOSTDATA_DIRECTORY']
    end

    result = upload_file_to_path(upload_path)

    render :inline => result
  end
  
end
