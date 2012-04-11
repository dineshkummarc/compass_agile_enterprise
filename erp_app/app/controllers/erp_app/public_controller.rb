module ErpApp
	class PublicController < ActionController::Base
    before_filter :set_file_support

    # DEPRECATED, use erp_app/public#download
    # def download_file
   #    path = params[:path]
   #    file_klass = FileAsset.type_by_extension(File.extname(path))
   #    if file_klass == Image
   #      send_file path, :type => "image/#{File.extname(path)}"
   #    else
   #      send_file path, :type => file_klass.content_type
   #    end
	  # end

    # TODO:
    # upload 1.1mb pdf - too large?
    # file manager upload broken
    # test X Send file in apache
    # reorder menuitems
    # drag and drop image into ckeditor uses bad (but somehow not broken, i.e. ../../images/) url (filesystem on firefox, chrome OK) 

    # Download Inline Example: /download/filename.ext?path=/directory    
    # Download Prompt Example: /download/filename.ext?path=/directory&disposition=attachment
    def download
      filename = "#{params[:filename]}.#{params[:format]}"
      disposition = params[:disposition] || 'inline'

      file = FileAsset.where(:name => filename)
      file = file.where(:directory => params[:path]) unless params[:path].blank?
      file = file.first

      unless file.nil?
        if file.has_capabilities?
          begin
            unless current_user == false
              current_user.with_capability(file, :download, nil) do
                serve_file(file, disposition)
              end
            else
              raise ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :text => ex.message and return
          rescue Exception=>ex
            render :text => "User does not have capability." and return
          end
        else
          serve_file(file, disposition)
        end
      else
        render :text => 'File not found.'
      end
    end

    protected

    def serve_file(file, disposition)
      type = (file.type == 'Image' ? "image/#{params[:format]}" : file.content_type)

      if Rails.application.config.erp_tech_svcs.file_storage == :s3
        path = File.join(file.directory,file.name).sub(%r{^/},'')
        options = { :response_content_disposition => disposition }
        options[:expires] = Rails.application.config.erp_tech_svcs.s3_url_expires_in_seconds if file.has_capabilities?
        redirect_to @file_support.bucket.objects[path].url_for(:read, options).to_s
      else
        # to use X-Sendfile or X-Accel-Redirect, set config.action_dispatch.x_sendfile_header in environment config file
        send_file File.join(Rails.root,file.directory,file.name), :type => type, :disposition => disposition
      end
    end

    def set_file_support
      @file_support = ErpTechSvcs::FileSupport::Base.new(:storage => Rails.application.config.erp_tech_svcs.file_storage)
    end

	end
end