class PartyObserver < ActiveRecord::Observer

  def after_save(party)
    begin
      PartySearchFact.update_search_fact(party)
    rescue
      logger.warn 'PartySearchFact/Solr update failed on Party.after_save'
    end
  end

end