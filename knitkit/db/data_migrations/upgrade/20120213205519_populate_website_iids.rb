class PopulateWebsiteIids
  
  def self.up
    #insert data here
    Website.all.each do |w|
      if w.internal_identifier.blank?
        w.internal_identifier = "site-#{w.id}"
        w.save
      end
    end
  end
  
  def self.down
    #remove data here
  end

end
