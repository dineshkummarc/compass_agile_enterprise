class AddContactPurposes
  
  def self.up
    
    [
      {:description => 'Default', :internal_identifier => 'default'},
      {:description => 'Home', :internal_identifier => 'home'},
      {:description => 'Work', :internal_identifier => 'work'},
      {:description => 'Billing', :internal_identifier => 'billing'},
      {:description => 'Temporary', :internal_identifier => 'temporary'},
      {:description => 'Tax Reporting', :internal_identifier => 'tax_reporting'},
      {:description => 'Recruiting', :internal_identifier => 'recruiting'},
      {:description => 'Employment Offer', :internal_identifier => 'employment_offer'},
      {:description => 'Business', :internal_identifier => 'business'},
      {:description => 'Personal', :internal_identifier => 'personal'},
      {:description => 'Fax', :internal_identifier => 'fax'},
      {:description => 'Mobile', :internal_identifier => 'mobile'},
      {:description => 'Emergency', :internal_identifier => 'emergency'},
      {:description => 'Shipping', :internal_identifier => 'shipping'},
      {:description => 'Other', :internal_identifier => 'other'},
    ].each do |item|
      contact_purpose = ContactPurpose.find_by_internal_identifier(item[:internal_identifier])
      ContactPurpose.create(:description => item[:description], :internal_identifier => item[:internal_identifier]) if contact_purpose.nil?
    end
    
  end
  
  def self.down
    [
      'default',
      'home',
      'work',
      'billing',
      'temporary',
      'tax_reporting',
      'recruiting',
      'employment_offer',
      'business',
      'personal',
      'fax',
      'mobile',
      'emergency',
      'shipping',
      'other',
    ].each do |item|
      contact_purpose = ContactPurpose.find_by_internal_identifier(item)
      contact_purpose.destroy unless contact_purpose.nil?
    end
  end

end
