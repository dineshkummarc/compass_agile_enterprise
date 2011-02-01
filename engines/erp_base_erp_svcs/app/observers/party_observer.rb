class PartyObserver < ActiveRecord::Observer

  def after_save(party)
    begin
      #PartySearchFact.update_search_fact(party) #Commented out due to custom OlPartySearchFact
      OlPartySearchFact.update_search_fact(party)
    rescue
    end
  end

  def after_create(party)
    begin
      #PartySearchFact.update_search_fact(party) #Commented out due to custom OlPartySearchFact
      OlPartySearchFact.update_search_fact(party)
    rescue
    end
  end

  # obsolete, replaced with :dependent => :destroy on party model
#  def after_destroy(party)
#    begin
#      sf = OlPartySearchFact.find_by_party_id(party.id)
#      sf.destroy
#    rescue
#    end
#  end

end