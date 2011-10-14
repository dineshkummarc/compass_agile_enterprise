class CreatePathsForSections
  
  def self.up
    WebsiteSection.all.each do |section|
      section.update_path!
    end
  end
  
  def self.down
    #remove data here
  end

end
