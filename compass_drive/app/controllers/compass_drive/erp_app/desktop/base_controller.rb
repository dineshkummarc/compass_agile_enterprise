module CompassDrive
  module ErpApp
    module Desktop
      class BaseController < ::ErpApp::Desktop::BaseController

        def index
          CompassDriveAsset.all

          render :json => []
        end

        def add_asset
          name = request.env['HTTP_X_FILE_NAME'].blank? ? params[:file_data].original_filename : request.env['HTTP_X_FILE_NAME']
          data = request.env['HTTP_X_FILE_NAME'].blank? ? params[:file_data] : request.raw_post

          compass_drive_asset = CompassDriveAsset.create(:name => name)
          compass_drive_asset.add_file(data)

          render :json => {:success => true}
        end

      end
    end#Desktop
  end#ErpApp
end#CompassDrive