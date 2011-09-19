class PartyObserver < ActiveRecord::Observer

  def after_save(party)
    begin
      PartySearchFact.update_search_fact(party)
    rescue
    end
  end

end