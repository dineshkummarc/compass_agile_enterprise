class ErpApp::Desktop::Knitkit::FileAssetsController < ErpApp::Desktop::FileManager::BaseController

  IMAGE_FILE_EXENTIONS_REGEX = /^.?[^\.]+\.(jpe?g|png|gif|tiff)$/

  def initialize
    @base_path = File.join(Rails.root, '/vendor/plugins/erp_app/public/file_assets/')
  end

  def expand_directory
    expand_file_directory(params[:node], :folders_only => false)
  end
  
end
