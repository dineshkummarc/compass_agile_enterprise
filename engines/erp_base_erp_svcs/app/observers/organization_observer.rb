class OrganizationObserver < ActiveRecord::Observer
  def after_save(organization)
    begin
      #PartySearchFact.update_search_fact(organization.business_party) #Commented out due to custom OlPartySearchFact
      OlPartySearchFact.update_search_fact(organization.business_party)
    rescue
    end
  end
end