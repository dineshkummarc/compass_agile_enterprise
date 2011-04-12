class ErpApp::Desktop::Knitkit::FileAssetsController < ErpApp::Desktop::FileManager::BaseController

  def base_path
    @base_path ||= File.join(Rails.root, '/vendor/plugins/erp_app/public/file_assets/')
  end

  def expand_directory
    expand_file_directory(params[:node], :folders_only => false)
  end
  
end
