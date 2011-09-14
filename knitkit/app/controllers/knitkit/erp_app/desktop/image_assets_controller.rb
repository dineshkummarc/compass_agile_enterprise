module Knitkit
  module ErpApp
    module Desktop
      class ImageAssetsController < FileAssetsController
        
        IMAGE_FILE_EXTENSIONS_REGEX = /^.?[^\.]+\.(jpe?g|png|PNG|gif|tiff)$/
      
        def base_path
          @base_path = nil
          if @context == :website
            @base_path = File.join(Rails.root, "/public", "/sites/site-#{@assets_model.id}", "images") unless @assets_model.nil?
          else
            @base_path = File.join(Rails.root, "/public", "images") unless @assets_model.nil?
          end
        end

        def get_images
          directory = (params[:directory] == 'root_node' or params[:directory].blank?) ? base_path : params[:directory]
          render :json => @assets_model.images.where("directory = ?", directory.gsub(Rails.root.to_s,'')).collect{|image|{:name => image.name, :shortName => image.name[0..20], :url => image.url}}
        end
        
      end
    end
  end
end
