module Knitkit
  module ErpApp
    module Desktop
      class FileAssetsController < ::ErpApp::Desktop::FileManager::BaseController
        skip_before_filter :verify_authenticity_token, :only => :upload_file
        skip_before_filter :require_login, :only => [:download_file_asset]
        before_filter :set_asset_model
        before_filter :set_root_node

        def base_path          
          if @root_node.nil?
            @base_path = nil
          else
            @base_path = File.join(@file_support.root, @root_node) 
          end

          @base_path
        end

        def expand_directory
          if @assets_model.nil?
            render :json => []
          else
            path = (params[:node] == ROOT_NODE) ? base_path : params[:node]
            render :json => @file_support.build_tree(path, :file_asset_holder => @assets_model, :preload => true)
          end
        end

        def create_file
          path = params[:path] == 'root_node' ? base_path : params[:path]
          name = params[:name]

          @assets_model.add_file('#Empty File', File.join(path, name))

          render :json => {:success => true}
        end

        def create_folder
          path = (params[:path] == 'root_node') ? base_path : params[:path]
          name = params[:name]

          path = File.join(@file_support.root,path) if path.index(@file_support.root).nil?

          @file_support.create_folder(path, name)
          render :json => {:success => true}
        end

        def upload_file
          if @context == Website
            capability_type = "view"
            capability_resource = "SiteFileAsset"
          else
            capability_type = "upload"
            capability_resource = "GlobalFileAsset"
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

        def save_move
          result          = {}
          path            = params[:node]
          new_parent_path = params[:parent_node]
          new_parent_path = @root_node if new_parent_path == ROOT_NODE

          if ErpTechSvcs::FileSupport.options[:storage] == :filesystem and !File.exists?(File.join(@file_support.root, path))
            result = {:success => false, :msg => 'File does not exist.'}
          else
            #path = path[1..path.length] if path[0] == "/"
            file = @assets_model.files.find(:first, :conditions => ['name = ? and directory = ?', ::File.basename(path), ::File.dirname(path)])
            file.move(new_parent_path)
            result = {:success => true, :msg => "#{File.basename(path)} was moved to #{new_parent_path} successfully"}
          end

          render :json => result
        end

        def delete_file
          if @context == Website
            capability_type = "view"
            capability_resource = "SiteFileAsset"
          else
            capability_type = "delete"
            capability_resource = "GlobalFileAsset"
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

        def rename_file
          path = params[:node]
          name = params[:file_name]

          result, message = @file_support.rename_file(File.join(@file_support.root,path), name)
          if result
            file = @assets_model.files.find(:first, :conditions => ['name = ? and directory = ?', ::File.basename(path), ::File.dirname(path)])
            file.name = name
            file.save
          end

          render :json =>  {:success => true, :message => message}
        end

        def update_security
          path   = params[:path]
          secure = params[:secure]
          roles  = ['admin', 'file_downloader']
          
          file = @assets_model.files.find(:first, :conditions => ['name = ? and directory = ?', ::File.basename(path), ::File.dirname(path)])
          roles << @assets_model.website_role_iid if @context == :website
          
          (secure == 'true') ? file.add_capability(:download, nil, roles) : file.remove_all_capabilities

          # if we're using S3, set file permissions to private or public_read   
          @file_support.set_permissions(path, ((secure == 'true') ? :private : :public_read)) if ErpTechSvcs::FileSupport.options[:storage] == :s3
          
          render :json =>  {:success => true}
        end

        # DEPRECATED, use erp_app/public#download
        def download_file_asset
          path = params[:path]

          file = @assets_model.files.find(:first, :conditions => ['name = ? and directory = ?', ::File.basename(path), ::File.dirname(path)])
          if(file.has_capabilities?)
            begin
              unless current_user == false
                current_user.with_capability(file, :download, nil) do
                  redirect_to file.data.url
                end
              else
                raise ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability
              end
            rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
              render :text => ex.message
            rescue Exception=>ex
              render :text => "User does not have capability."
            end
          else
            redirect_to file.data.url
          end
        end

        protected

        def set_file_support
          @file_support = ErpTechSvcs::FileSupport::Base.new(:storage => ErpTechSvcs::FileSupport.options[:storage])
        end

        def set_root_node
          @root_node = nil

          if @context == :website
            @root_node = "/#{Rails.application.config.erp_tech_svcs.file_assets_location}/sites/#{@assets_model.iid}" unless @assets_model.nil?
          else
            @root_node = "/#{Rails.application.config.erp_tech_svcs.file_assets_location}/shared_site_files"
          end

          @root_node
        end

        def set_asset_model
          @context = params[:context].to_sym

          if @context == :website
            #get website id this can be an xhr request or regular
            website_id = request.env['HTTP_X_WEBSITEID'].blank? ? params[:website_id] : request.env['HTTP_X_WEBSITEID']
            (@assets_model = website_id.blank? ? nil : Website.find(website_id))

            render :inline => {:success => false, :error => "No Website Selected"}.to_json if (@assets_model.nil? && params[:action] != "base_path")
          else
            @assets_model = CompassAeInstance.first
          end
        end
  
      end#FileAssetsController
    end#Desktop
  end#ErpApp
end#Knitkit
