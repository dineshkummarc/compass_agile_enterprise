module Knitkit
  module ErpApp
    module Desktop
      class ImageAssetsController < FileAssetsController
        
        IMAGE_FILE_EXTENSIONS_REGEX = /^.?[^\.]+\.(jpe?g|png|PNG|gif|tiff)$/
        
        before_filter :set_website
        
        def base_path
          @base_path = nil
          @base_path ||= File.join(Rails.root, "/public", "/sites/site-#{@website.id}", "images") unless @website.nil?
        end

        def get_images
          render :json => @website.images.collect{|image|{:name => image.name, :shortName => image.name[0..20], :url => image.url}}
        end
        
      end
    end
  end
end
