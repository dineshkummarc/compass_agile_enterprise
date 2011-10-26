module Knitkit
  module ErpApp
    module Desktop
      class ImageAssetsController < FileAssetsController
        
        IMAGE_FILE_EXTENSIONS_REGEX = /^.?[^\.]+\.(jpe?g|png|PNG|gif|tiff)$/

        def base_path
          @base_path = nil
          if @context == :website
            @base_path = File.join(@file_support.root,"/sites/site-#{@assets_model.id}", "images") unless @assets_model.nil?
          else
            @base_path = File.join(@file_support.root,"/images") unless @assets_model.nil?
          end
        end

        def get_images
          directory = (params[:directory] == 'root_node' or params[:directory].blank?) ? base_path : params[:directory]
          render :json => @assets_model.images.select{|image| image.directory == directory.sub(@file_support.root,'')}.collect{|image|{:name => image.name, :shortName => image.name[0..15], :url => image.data.url}}
        end

        protected

        def set_file_support
          @file_support = ErpTechSvcs::FileSupport::Base.new(:storage => ErpTechSvcs::FileSupport.options[:storage])
        end
        
      end#ImageAssetsController
    end#Desktop
  end#ErpApp
end#Knitkit
