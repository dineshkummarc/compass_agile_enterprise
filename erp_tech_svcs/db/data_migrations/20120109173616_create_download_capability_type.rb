class CreateDownloadCapabilityType
  
  def self.up
    CapabilityType.create(:internal_identifier => 'download', :description => 'Download')
    Role.create(:description => 'File Downloader', :internal_identifier => 'file_downloader')
  end
  
  def self.down
    CapabilityType.where("internal_identifier = 'download'").first.destroy unless Role.where("internal_identifier = 'download'").first.nil?
    Role.where("internal_identifier = 'file_downloader'").first.destroy  unless Role.where("internal_identifier = 'file_downloader'").first.nil?
  end

end
