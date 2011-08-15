module ErpApp
	class PublicController < ActionController::Base

	  def download_file
		path = params[:path]

		send_file path, :type=>"text/plain"
	  end
	end
end
