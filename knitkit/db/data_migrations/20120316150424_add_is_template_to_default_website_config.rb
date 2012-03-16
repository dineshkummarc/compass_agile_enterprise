class AddIsTemplateToDefaultWebsiteConfig
  
  def self.up
    default_website_config = Configuration.where('internal_identifier = ?', 'default_website_configuration').all
    unless default_website_config.empty?
      config = default_website_config.find{|config| config.websites.empty?}
      config.is_template = true
      config.save
    end
  end
  
  def self.down
    #remove data here
  end

end
