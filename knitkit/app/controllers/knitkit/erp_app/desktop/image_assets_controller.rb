module Knitkit
  module ErpApp
    module Desktop
      class ImageAssetsController < FileAssetsController
        
        def get_images
          directory = (params[:directory] == 'root_node' or params[:directory].blank?) ? base_path : params[:directory]
          # this @assets_model.images.select should be refactored into a query
          render :json => @assets_model.images.select{|image| image.directory == directory.sub(@file_support.root,'')}.collect{|image|{:name => image.name, :shortName => image.name[0..15], :url => image.data.url}}
        end

        def upload_file
          if @context == Website
            capability_type = "view"
            capability_resource = "SiteImageAsset"
          else
            capability_type = "upload"
            capability_resource = "GlobalImageAsset"
          end

          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, capability_type, capability_resource) do
              result = {}
              upload_path = request.env['HTTP_X_DIRECTORY'].blank? ? params[:directory] : request.env['HTTP_X_DIRECTORY']
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
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def delete_file
          if @context == Website
            capability_type = "view"
            capability_resource = "SiteImageAsset"
          else
            capability_type = "delete"
            capability_resource = "GlobalImageAsset"
          end

          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, capability_type, capability_resource) do
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
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        protected

        def set_root_node
          @root_node = nil

          if @context == :website
            @root_node = File.join("/public/sites/#{@assets_model.iid}", "images") unless @assets_model.nil?
          else
            @root_node = "/public/images"
          end

          @root_node
        end

        def set_file_support
          @file_support = ErpTechSvcs::FileSupport::Base.new(:storage => Rails.application.config.erp_tech_svcs.file_storage)
        end
        
      end#ImageAssetsController
    end#Desktop
  end#ErpApp
end#Knitkit
