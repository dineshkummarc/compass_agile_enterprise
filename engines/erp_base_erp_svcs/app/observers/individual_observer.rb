class IndividualObserver < ActiveRecord::Observer

#  def after_save(individual)
#    begin
      #PartySearchFact.update_search_fact(individual.party)
      # updating search fact here is redundant, Party observer is being called via Individual.after_save => Party.save => PartyObserver.after_save
#    rescue
#    end
#  end
end