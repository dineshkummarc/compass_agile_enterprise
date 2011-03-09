class PartySearchFact < ActiveRecord::Base
acts_as_solr :fields => [
    :party_id,
    :eid,
    :type,
    :roles,
    :party_business_party_type,
    :party_description,
    :user_login,
    :individual_current_last_name,
    :individual_current_first_name,
    :individual_current_middle_name,
    :individual_birth_date,
    :individual_ssn,
    :party_phone_number,
    :party_email_address,
    :party_address_1,
    :party_address_2,
    :party_primary_address_city,
    :party_primary_address_state,
    :party_primary_address_zip,
    :party_primary_address_country
    ]

  def PartySearchFact.parties_find_by_solr(query, options={})
    results = PartySearchFact.find_by_solr(query, options)
    if results.docs.size > 0
      parties = []
      results.docs.each do |party|
        parties << Party.find(party.party_id)
      end

      #****!!! Custom hack to ActsAsSolr plugin to make the docs exchange
      results.exchange = parties
    end
    results
  end

  def PartySearchFact.destroy_search_fact(party)
    sf = PartySearchFact.find(:first, :conditions => ["party_id = ?", party.id])

    if sf.nil?
      return
    end

    sf.destroy
  end

  def PartySearchFact.update_search_fact(party)
    sf = PartySearchFact.find(:first, :conditions => ["party_id = ?", party.id])

    if sf.nil?
      sf = PartySearchFact.create
    end

    sf.update_search_fact(party)
  end

  def update_search_fact(party)
    self.update_attributes(
      :party_id => party.id,
      :eid => party.enterprise_identifier,
      :roles => (party.user.roles.collect { |role| role.internal_identifier }.join(" ") rescue nil),
      :party_description => party.description,
      :party_business_party_type => party.business_party_type,
      :user_login => (party.user.login rescue nil),
      :individual_current_last_name => (party.business_party.current_last_name rescue nil),
      :individual_current_first_name => (party.business_party.current_first_name rescue nil),
      :individual_current_middle_name => (party.business_party.current_middle_name rescue nil),
      :individual_birth_date => (party.business_party.birth_date rescue nil),
      :individual_social_security_number => (party.business_party.ssn_last_four rescue nil),
      :party_primary_phone_phone_number => (party.primary_phone rescue nil),
      :party_primary_email_email_address => (party.primary_email rescue nil),
      :party_primary_address_address_line_1 => (party.primary_address.address_line_1 rescue nil),
      :party_primary_address_address_line_2 => (party.primary_address.address_line_2 rescue nil),
      :party_primary_address_city => (party.primary_address.city rescue nil),
      :party_primary_address_state => (party.primary_address.state rescue nil),
      :party_primary_address_zip => (party.primary_address.zip rescue nil),
      :party_primary_address_country => (party.primary_address.country rescue nil)
      )
  end

end