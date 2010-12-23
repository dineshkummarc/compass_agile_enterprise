class ContactObserver < ActiveRecord::Observer

  def after_save(contact)
    begin
      #PartySearchFact.update_search_fact(contact.party) #Commented out due to custom OlPartySearchFact
      OlPartySearchFact.update_search_fact(contact.party)
    rescue
    end
  end

  def after_destroy(contact)
    begin
      party = Party.find(contact.party.id)
      #PartySearchFact.update_search_fact(party) #Commented out due to custom OlPartySearchFact
      OlPartySearchFact.update_search_fact(party)
    rescue
    end
  end
end
