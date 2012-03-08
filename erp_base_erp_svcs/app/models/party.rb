class Party < ActiveRecord::Base
  has_notes
  
  has_many   :contacts, :dependent => :destroy
  has_many   :created_notes, :class_name => 'Note', :foreign_key => 'created_by_id'
  belongs_to :business_party, :polymorphic => true
  has_many   :party_roles, :dependent => :destroy
	has_many   :role_types, :through => :party_roles
	
	attr_reader :relationships
  attr_writer :create_relationship

  def self.search(options = {})
    options[:sort] = 'description' if options[:sort].blank?

    parties = Party.where("LOWER(description) LIKE ?", "%#{options[:query].downcase}%")
    parties = parties.order("#{options[:sort]} #{options[:dir]}")
    parties.paginate(:page => options[:page], :per_page => options[:per_page])
  end

  def self.do_search(options = {})
    parties = Party.search(options)
  end

  # Gathers all party relationships that contain this particular party id
  # in either the from or to side of the relationship.
  def relationships
    @relationships ||= PartyRelationship.where('party_id_from = ? OR party_id_to = ?', id, id)
  end

  # Creates a new PartyRelationship for this particular
  # party instance.
  def create_relationship(description, to_party_id)
    PartyRelationship.create(:description => description, :party_id_from => id, :party_id_to => to_party_id)
  end

  # Callback
	def after_destroy
    if self.business_party
      self.business_party.destroy
    end
	end

  def has_phone_number?(phone_number)
    result = nil
    self.contacts.each do |c|
      if c.contact_mechanism_type == 'PhoneNumber'
        if c.contact_mechanism.phone_number == phone_number
          result = true
        end
      end
    end
    result
  end

  def has_zip_code?(zip)
    result = nil
    self.contacts.each do |c|
      if c.contact_mechanism_type == 'PostalAddress'
        if c.contact_mechanism.zip == zip
          result = true
        end
      end
    end
    result
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
    table_name = contact_mechanism_class.name.tableize

    contacts = self.contacts.joins("inner join #{table_name} on #{table_name}.id = contact_mechanism_id and contact_mechanism_type = '#{contact_mechanism_class.name}'")

    contacts.collect(&:contact_mechanism)
  end

  def find_contact(contact_mechanism_class, contact_mechanism_args={}, contact_purposes=[])
    conditions = ''

    table_name = contact_mechanism_class.name.tableize

    contact_mechanism_args.each do |key, value|
      next if key == 'updated_at' or key == 'created_at' or key == 'id'
      conditions += " #{table_name}.#{key} = '#{value}' and" unless value.nil?
    end unless contact_mechanism_args.nil?

    conditions = conditions[0..conditions.length - 5] unless conditions == ''
    
    self.contacts.joins("inner join #{table_name} on #{table_name}.id = contact_mechanism_id and contact_mechanism_type = '#{contact_mechanism_class.name}'
                                   inner join contact_purposes_contacts on contact_purposes_contacts.contact_id = contacts.id
                                   and contact_purposes_contacts.contact_purpose_id in (#{contact_purposes.collect{|item| item.attributes["id"]}.join(',')})").where(conditions).first
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
    
    contact_mechanism
  end

  # tries to update contact by purpose
  # if contact doesn't exist, it adds it
  def update_or_add_contact_with_purpose(contact_mechanism_class, contact_purpose, contact_mechanism_args)
    if return_value = update_contact_with_purpose(contact_mechanism_class, contact_purpose, contact_mechanism_args)
      return_value
    else
      add_contact(contact_mechanism_class, contact_mechanism_args, [contact_purpose])
    end
  end
  
  # looks for a contact matching on purpose
  # if it exists, it updates it, if not returns false
  def update_contact_with_purpose(contact_mechanism_class, contact_purpose, contact_mechanism_args)
    contact = find_contact_with_purpose(contact_mechanism_class, contact_purpose)
    contact.nil? ? false : update_contact(contact_mechanism_class, contact, contact_mechanism_args)
  end

  def update_contact(contact_mechanism_class, contact, contact_mechanism_args)
    contact_mechanism_class.update(contact.contact_mechanism, contact_mechanism_args)
  end

  def get_contact_by_method(m)
    method_name = m.split('_')
    return nil if method_name.size < 3 or method_name.size > 4
    # handles 1 or 2 segment contact purposes (i.e. home or employment_offer)
    # contact mechanism must be 2 segments, (i.e. email_address, postal_address, phone_number)
    if method_name.size == 4
      purpose = method_name[0] + '_' + method_name[1]
      klass = method_name[2] + '_' + method_name[3]
    else
      purpose = method_name[0]
      klass = method_name[1] + '_' + method_name[2]
    end
    
    contact_purpose = ContactPurpose.find_by_internal_identifier(purpose)
    if contact_purpose.nil? or !Object.const_defined?(klass.camelize)
      return nil
    else
      find_contact_mechanism_with_purpose(klass.camelize.constantize, contact_purpose)
    end
  end

  def respond_to?(m)
    ((get_contact_by_method(m.to_s).nil? ? super : true)) rescue super
  end
  
  def method_missing(m, *args, &block)
    value = get_contact_by_method(m.to_s)
    (value.nil?) ? super : (return value)
  end
  
  #************************************************************************************************
  #** End
  #************************************************************************************************
end
