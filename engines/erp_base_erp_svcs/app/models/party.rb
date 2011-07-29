class Party < ActiveRecord::Base
  #************************************************************************************************
  #* Contact relationships
  #************************************************************************************************
  
  has_many :contacts, :dependent => :destroy
  
  #************************************************************************************************
  #* End
  #************************************************************************************************

  #add the has_notes mixin to party so a pary can have notes
  has_notes

  has_many :created_notes, :class_name => 'Note', :foreign_key => 'created_by_id'

  # business_party is an interface implemented by the class Party
  # that provides access to the person or organization that is
  # identified by an instance of Party.
  belongs_to  :business_party, :polymorphic => true
  attr_reader :relationships
  attr_writer :create_relationship

  has_many :party_roles, :dependent => :destroy
	has_many :role_types, :through => :party_roles

  # Gathers all party relationships that contain this particular party id
  # in either the from or to side of the relationship.
  def relationships
    @relationships ||= PartyRelationship.find(:all, :conditions => ['party_id_from = ? OR party_id_to = ?', id, id])
  end

  # Creates a new PartyRelationship for this particular
  # party instance.
  def create_relationship(description, to_party_id)
    PartyRelationship.create(:description => description, :party_id_from => id, :party_id_to => to_party_id)
  end

	#**********************************************************************
	# I have replaced this with a has_many :through => AgreementPartyRoles
	# will delete this if nothing breaks - rak
	#**********************************************************************
  # Wrapper to get all party agreements
  # def agreements
  #     AgreementPartyRole.find(:all, :joins => [:party], :conditions => ['party_id = ?', id])
  # end

  # Callback
	def after_destroy
    if self.business_party
      self.business_party.destroy
    end
	end

  # Return primary phone number
  def primary_phone_number
    find_contact_mechanism_with_purpose(PhoneNumber, ContactPurpose.find_by_internal_identifier('personal'))    
  end

  def primary_phone_number=(phone_number)
    contact_mechanism_args = {
      :phone_number => phone_number, 
      :description => "personal phone number"
    }
    update_or_add_contact_with_purpose(PhoneNumber, ContactPurpose.find_by_internal_identifier('personal'), contact_mechanism_args)
  end

  # Return primary email
  def primary_email_address
    find_contact_mechanism_with_purpose(EmailAddress, ContactPurpose.find_by_internal_identifier('personal'))    
  end

  def primary_email_address=(email)
    contact_mechanism_args = {
      :email_address => email.strip(), 
      :description => "personal e-mail"
    }
    update_or_add_contact_with_purpose(EmailAddress, ContactPurpose.find_by_internal_identifier('personal'), contact_mechanism_args)
  end

  def billing_address
    find_contact_mechanism_with_purpose(PostalAddress, ContactPurpose.find_by_internal_identifier('billing'))    
  end

  def billing_address=(address={})
    update_or_add_contact_with_purpose(PostalAddress, ContactPurpose.find_by_internal_identifier('billing'), address)
  end

  def shipping_address
    find_contact_mechanism_with_purpose(PostalAddress, ContactPurpose.find_by_internal_identifier('shipping'))    
  end

  def shipping_address=(address={})
    update_or_add_contact_with_purpose(PostalAddress, ContactPurpose.find_by_internal_identifier('shipping'), address)
  end

  # Return primary address
  def primary_address
    find_contact_mechanism_with_purpose(PostalAddress, ContactPurpose.find_by_internal_identifier('home'))    
  end

  def primary_address=(address={})
    update_or_add_contact_with_purpose(PostalAddress, ContactPurpose.find_by_internal_identifier('home'), address)
  end

  # Return email
  def email
    primary_email.nil? ? '' : primary_email
  end

  # Return primary address street line 1
  def primary_street
    primary_address.nil? ? nil : primary_address.address_line_1
  end

  # Return primary address city
  def primary_city
    primary_address.nil? ? nil : primary_address.city
  end

  # Return primary address state
  def primary_state
    primary_address.nil? ? nil : primary_address.state
  end

  # Return primary zip code
  def primary_zip_code
    primary_address.nil? ? nil : primary_address.zip
  end

  # Return primary address country
  def primary_country
    primary_address.nil? ? nil : primary_address.country
  end

  # Return primary phone number
  def primary_phone
    primary_phone_number.nil? ? nil : primary_phone_number.phone_number
    #nil
  end

  def primary_email
    primary_email_address.nil? ? nil : primary_email_address.email_address
  end

  # return primary credit card
  def primary_credit_card
    return get_credit_card('primary')
  end

  # return credit card by credit card account purpose using internal identifier
  def get_credit_card(internal_identifier)
    self.credit_card_account_party_roles.each do |ccapr|
      if ccapr.credit_card_account.credit_card_account_purpose.internal_identifier.eql?(internal_identifier)
        return ccapr.credit_card
      end
    end 
    return nil  
  end

  def has_phone_number?(phone)
    self.contacts.each do |c|
      if c.contact_mechanism_type == 'PhoneNumber'
        if c.contact_mechanism.eql_to?(phone)
          return true
        end
      end
    end
    return false
  end

  def has_zip_code?(zip)
    self.contacts.each do |c|
      if c.contact_mechanism_type == 'PostalAddress'
        if c.contact_mechanism.zip_eql_to?(zip)
          return true
        end
      end
    end
    return false
  end

  # Alias for to_s
  def to_label
    to_s
	end

	def to_s
    "#{description}"
	end
  

  #************************************************************************************************
  #** Contact Methods
  #************************************************************************************************

  def find_contact_mechanism_with_purpose(contact_mechanism_class, contact_purpose)
    contact_mechanism = nil

    contact = self.find_contact_with_purpose(contact_mechanism_class, contact_purpose)
    contact_mechanism = contact.contact_mechanism unless contact.nil?

    contact_mechanism
  end

  def find_contact_with_purpose(contact_mechanism_class, contact_purpose)
    contact = nil

    #if a symbol or string was passed get the model
    unless contact_purpose.is_a? ContactPurpose
      contact_purpose = ContactPurpose.find_by_internal_identifier(contact_purpose.to_s)
    end

    contact = self.find_contact(contact_mechanism_class, nil, [contact_purpose])
    
    contact
  end

  def find_all_contacts_by_contact_mechanism(contact_mechanism_class)
    table_name = contact_mechanism_class.class_name.tableize

    contacts = self.contacts.find(:all,
      :joins => "inner join #{table_name} on #{table_name}.id = contact_mechanism_id and contact_mechanism_type = '#{contact_mechanism_class.class_name}'")

    contacts.collect(&:contact_mechanism)
  end

  def find_contact(contact_mechanism_class, contact_mechanism_args={}, contact_purposes=[])
    conditions = ''

    table_name = contact_mechanism_class.class_name.tableize

    contact_mechanism_args.each do |key, value|
      begin
        conditions += " #{table_name}.#{key} = '#{value}' and"
      end unless value.nil?
    end unless contact_mechanism_args.nil?

    unless conditions == ''
      conditions = conditions[0..conditions.length - 5]
    end

    contact = self.contacts.find(:first,
      :joins => "inner join #{table_name} on #{table_name}.id = contact_mechanism_id and contact_mechanism_type = '#{contact_mechanism_class.class_name}'
                 inner join contact_purposes_contacts on contact_purposes_contacts.contact_id = contacts.id and contact_purposes_contacts.contact_purpose_id in (#{contact_purposes.collect{|item| item.attributes["id"]}.join(',')})",
      :conditions => conditions)

    contact
  end

  # looks for contacts matching on value and purpose
  # if a contact exists, it updates, if not, it adds it
  def add_contact(contact_mechanism_class, contact_mechanism_args={}, contact_purposes=[])
    contact_purposes = [contact_purposes] if !contact_purposes.kind_of?(Array) # gracefully handle a single purpose not in an array
    contact = find_contact(contact_mechanism_class, contact_mechanism_args, contact_purposes)
    if contact.nil?
      contact_mechanism = contact_mechanism_class.new(contact_mechanism_args)
      contact_mechanism.contact.party = self
      contact_mechanism.contact.contact_purposes = contact_purposes
      contact_mechanism.contact.save
      contact_mechanism.save

      self.contacts << contact_mechanism.contact
    else
      contact_mechanism = update_contact(contact_mechanism_class, contact, contact_mechanism_args)
    end
    
    return contact_mechanism
  end

  # tries to update contact by purpose
  # if contact doesn't exist, it adds it
  def update_or_add_contact_with_purpose(contact_mechanism_class, contact_purpose, contact_mechanism_args)
    if return_value = update_contact_with_purpose(contact_mechanism_class, contact_purpose, contact_mechanism_args)
      return return_value
    else
      return add_contact(contact_mechanism_class, contact_mechanism_args, [contact_purpose])
    end
  end
  
  # looks for a contact matching on purpose
  # if it exists, it updates it, if not returns false
  def update_contact_with_purpose(contact_mechanism_class, contact_purpose, contact_mechanism_args)
    contact = find_contact_with_purpose(contact_mechanism_class, contact_purpose)
    if !contact.nil?
      return update_contact(contact_mechanism_class, contact, contact_mechanism_args)
    else
      return false
    end
  end

  def update_contact(contact_mechanism_class, contact, contact_mechanism_args)
    contact_mechanism_class.update(contact.contact_mechanism, contact_mechanism_args)
  end

  #************************************************************************************************
  #** End
  #************************************************************************************************
end
