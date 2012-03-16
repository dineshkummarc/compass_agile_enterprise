class AddPrimaryHostToWebsiteConfiguration
  
  def self.up
    website_setup_category = Category.find_by_internal_identifier('website_setup')
    configuration = ::Configuration.find_template('default_website_configuration')

    primary_host_config_item_type = ConfigurationItemType.create(
      :description => 'Primary Host',
      :internal_identifier => 'primary_host',
      :allow_user_defined_options => true
    )
    CategoryClassification.create(:category => website_setup_category, :classification => primary_host_config_item_type)
    configuration.configuration_item_types << primary_host_config_item_type
    configuration.save

    #update existing websites
    Website.all.each do |website|
      website_config = website.configurations.first
      if(website_config.internal_identifier == 'website_setup')
        website_config.configuration_item_types << primary_host_config_item_type
        website_config.add_configuration_item(primary_host_config_item_type, website.hosts.first.host)
        website_config.save
      end
    end
  end
  
  def self.down
    #remove data here
  end

end
