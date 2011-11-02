class AddIidToSectionsContents
  
  def self.up
    WebsiteSection.all.each do |section|
      if section.internal_identifier.nil?
        section.internal_identifier = section.permalink
        section.save
      end
    end

    Content.all.each do |content|
      if content.internal_identifier.nil?
        content.internal_identifier = content.permalink
        content.save
      end
    end
  end
  
  def self.down
    #remove data here
  end

end
