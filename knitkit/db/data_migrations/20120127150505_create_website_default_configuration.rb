class CreateWebsiteDefaultConfiguration
  
  def self.up
    unless ::Configuration.find_template('default_website_configuration')
      website_setup_category = Category.create(:description => 'Website Setup', :internal_identifier => 'website_setup')

      #configuration
      configuration = Configuration.create(
        :description => 'Default Website Configuration',
        :internal_identifier => 'default_website_configuration',
        :is_template => true
      )

      login_url_config_item_type = ConfigurationItemType.create(
        :description => 'Login Url',
        :internal_identifier => 'login_url',
        :allow_user_defined_options => true
      )
      CategoryClassification.create(:category => website_setup_category, :classification => login_url_config_item_type)
      configuration.configuration_item_types << login_url_config_item_type

      home_page_url_config_item_type = ConfigurationItemType.create(
        :description => 'Homepage Url',
        :internal_identifier => 'homepage_url',
        :allow_user_defined_options => true
      )
      CategoryClassification.create(:category => website_setup_category, :classification => home_page_url_config_item_type)
      configuration.configuration_item_types << home_page_url_config_item_type

      contact_us_email_address_item_type = ConfigurationItemType.create(
        :description => 'Contact Us Email',
        :internal_identifier => 'contact_us_email_address',
        :allow_user_defined_options => true
      )
      CategoryClassification.create(:category => website_setup_category, :classification => contact_us_email_address_item_type)
      configuration.configuration_item_types << contact_us_email_address_item_type
    
      #password strength
      simple_password_option = ConfigurationOption.create(
        :description => 'Simple password',
        :comment => 'must be at least 8 characters long and start and end with a letter',
        :internal_identifier => 'simple_password_regex',
        :value => '^[A-Za-z]\w{6,}[A-Za-z]$'
      )

      complex_password_option = ConfigurationOption.create(
        :description => 'Complex password',
        :comment => 'must be at least 10 characters, must contain at least one lower case letter, one upper case letter, one digit and one special character, valid special characters are @#$%^&+=',
        :internal_identifier => 'complex_password_regex',
        :value => '^.*(?=.{10,})(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=]).*$'
      )

      password_strength_config_item_type = ConfigurationItemType.create(
        :description => 'Password Strength',
        :internal_identifier => 'password_strength_regex'
      )
      CategoryClassification.create(:category => website_setup_category, :classification => password_strength_config_item_type)

      password_strength_config_item_type.configuration_options << complex_password_option
      password_strength_config_item_type.add_default_configuration_option(simple_password_option)
      password_strength_config_item_type.save
      configuration.configuration_item_types << password_strength_config_item_type

      configuration.save
    end
  end
  
  def self.down
    #remove data here
  end

end
