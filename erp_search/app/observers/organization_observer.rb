class OrganizationObserver < ActiveRecord::Observer

# NOTE: updating search fact here is redundant, 
#       Party observer is being called via Organization.after_save => Party.save => PartyObserver.after_save
  
end