class PartyObserver < ActiveRecord::Observer
  def after_save(party)
    begin
      OlPartySearchFact.update_search_fact(party)
    rescue
    end
  end

  def after_create(party)
    begin
      OlPartySearchFact.update_search_fact(party)
    rescue
    end
  end
end