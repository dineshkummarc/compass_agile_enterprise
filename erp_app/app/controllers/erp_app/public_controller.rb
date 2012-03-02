module ErpApp
	class PublicController < ActionController::Base
	  def download_file
      path = params[:path]

      file_klass = FileAsset.type_by_extension(File.extname(path))
      if file_klass == Image
        send_file path, :type => "image/#{File.extname(path)}"
      else
        send_file path, :type => file_klass.content_type
      end

	  end
	end
end