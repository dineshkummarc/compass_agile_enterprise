module Knitkit
  module ErpApp
    module Desktop
class FileAssetsController < ::ErpApp::Desktop::FileManager::BaseController

  def base_path
    @base_path ||= File.join(Rails.root, '/public/file_assets/')
  end

  def expand_directory
    expand_file_directory(params[:node], :folders_only => false)
  end
  
end
end
end
end
