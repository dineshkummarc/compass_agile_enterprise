class ContactObserver < ActiveRecord::Observer

  def after_save(contact)
    begin
      PartySearchFact.update_search_fact(contact.party)
    rescue
    end
  end

  def after_destroy(contact)
    begin
      PartySearchFact.update_search_fact(contact.party)
    rescue
    end
  end
end
