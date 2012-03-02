module ErpInvoicing
  module ErpApp
    module Shared
      class FilesController < ::ErpApp::Desktop::FileManager::BaseController
        before_filter :set_invoice

        def base_path
          @base_path = File.join(@file_support.root, 'invoices', @invoice.invoice_number)
        end

        def upload_file
          clear_files

          result = {}
          upload_path = request.env['HTTP_EXTRAPOSTDATA_DIRECTORY'].blank? ? params[:directory] : request.env['HTTP_EXTRAPOSTDATA_DIRECTORY']
          name = request.env['HTTP_X_FILE_NAME'].blank? ? params[:file_data].original_filename : request.env['HTTP_X_FILE_NAME']
          data = request.env['HTTP_X_FILE_NAME'].blank? ? params[:file_data] : request.raw_post

          begin
            @invoice.add_file(data, File.join(base_path, name))
            result = {:success => true}
          rescue Exception=>ex
            logger.error ex.message
            logger.error ex.backtrace.join("\n")
            result = {:success => false, :error => "Error uploading file."}
          end

          #the awesome uploader widget whats this to mime type text, leave it render :inline
          render :inline => result.to_json
        end

        def set_invoice
          @invoice = Invoice.find(params[:invoice_id])
        end

        def set_file_support
          @file_support = ErpTechSvcs::FileSupport::Base.new(:storage => ErpTechSvcs::FileSupport.options[:storage])
        end

        private

        def clear_files
          @invoice.files.each do |file|
            result, message, is_folder = @file_support.delete_file(File.join(@file_support.root,file.directory,file.name))
            file.destroy
          end
        end

      end#FilesController
    end#Shared
  end#ErpApp
end#ErpInvoicing