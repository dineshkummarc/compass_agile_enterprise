class UpdateFileAssetDirs
  
  def self.up
    FileAsset.all.each do |file_asset|
      file_asset.directory = file_asset.attributes["directory"].gsub("/public//","")

      klass = FileAsset.type_for(file_asset.name)
      unless klass.nil?
        klass = klass.constantize
        content_type = klass == Image ? "image/#{file_asset.extname.downcase}" : klass.content_type
        file_asset.data_content_type = content_type
      end

      file_asset.data_file_name = file_asset.name
      file_asset.save
    end
  end
  
  def self.down
    #remove data here
  end

end
