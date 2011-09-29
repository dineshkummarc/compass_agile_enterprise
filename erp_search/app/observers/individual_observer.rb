class IndividualObserver < ActiveRecord::Observer

# NOTE: updating search fact here is redundant, 
#       Party observer is being called via Individual.after_save => Party.save => PartyObserver.after_save

end