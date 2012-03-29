class PartySearchFact < ActiveRecord::Base
  after_destroy :sunspot_commit
  
  belongs_to :party

  Rails.logger.debug "########### Included BASE PartySearchFact"
  
  searchable do
    integer :party_id
    integer :user_id
    string :eid    
    string :type
    string :roles, :multiple => true do
      roles.split(/,\s*/) unless roles.nil?
    end
    text :party_description
    string :party_description
    string :party_business_party_type    
    text :user_login
    text :individual_current_last_name
    text :individual_current_first_name
    string :individual_current_last_name # we need to search AND sort on first and last name
    string :individual_current_first_name
    string :individual_current_middle_name    
    string :individual_birth_date
    text :individual_ssn    
    text :party_phone_number
    text :party_email_address    
    string :party_email_address    
    text :party_address_1
    text :party_address_2    
    text :party_primary_address_city
    text :party_primary_address_state    
    text :party_primary_address_zip
    string :party_primary_address_country    
    string :user_enabled
    string :user_type
    string :account_number, :multiple => true do
      account_number.split(/,\s*/) unless account_number.nil?
    end
  end
  
  def self.update_search_fact(party)    
    sf = PartySearchFact.find(:first, :conditions => ["party_id = ?", party.id])

    sf = PartySearchFact.create(:party_id => party.id) if sf.nil?
    sf.update_search_fact(party)
  end

  def self.destroy_search_fact(party)
    sf = PartySearchFact.find(:first, :conditions => ["party_id = ?", party.id])

    return if sf.nil?

    sf.destroy
  end

  def update_search_fact(party)
    self.update_attributes(
        :party_id => party.id,
        :eid => party.enterprise_identifier,
        :roles => (party.user.roles.map { |role| role.internal_identifier }.join(',') rescue ''),
        :party_description => party.description,
        :party_business_party_type => party.business_party_type,
        :user_login => (party.user.username rescue ''),
        :user_id => (party.user.id rescue ''),
        :individual_current_last_name => (party.business_party.current_last_name rescue ''),
        :individual_current_first_name => (party.business_party.current_first_name rescue ''),
        :individual_current_middle_name => (party.business_party.current_middle_name rescue ''),
        :individual_birth_date => (party.business_party.birth_date rescue ''),
        :individual_ssn => (party.business_party.ssn_last_four rescue ''),
        :party_phone_number => (party.personal_phone_number.phone_number rescue ''),
        :party_email_address => (party.personal_email_address.email_address rescue ''),
        :party_address_1 => (party.home_postal_address.address_line_1 rescue ''),
        :party_address_2 => (party.home_postal_address.address_line_2 rescue ''),
        :party_primary_address_city => (party.home_postal_address.city rescue ''),
        :party_primary_address_state => (party.home_postal_address.state rescue ''),
        :party_primary_address_zip => (party.home_postal_address.zip rescue ''),
        :party_primary_address_country => (party.home_postal_address.country rescue ''),
        :user_enabled => (party.user.enabled rescue false),
        :user_type => (party.user.attributes['type'] rescue ''),
        :account_number => (BillingAccount.scoped.includes(:financial_txn_account => {:biz_txn_acct_root => :biz_txn_acct_party_roles}).where(:financial_txn_accounts => {:biz_txn_acct_roots => {:biz_txn_acct_party_roles => {:party_id => party.id }}}).map { |a| a.account_number }.join(',') rescue '')
        )
    Sunspot.commit
  end

  def sunspot_commit
    Sunspot.commit    
  end

end
