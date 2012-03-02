class AddWebsiteConfigs
  
  def self.up
    #insert data here
    Website.all.each do |w|
      if w.configurations.empty?
        config = Configuration.find_by_internal_identifier('default_website_configuration').clone(true)
        config.update_configuration_item(ConfigurationItemType.find_by_internal_identifier('contact_us_email_address'), w.email)
        w.configurations << config
        w.save
      end
    end
  end
  
  def self.down
    #remove data here
  end

end
