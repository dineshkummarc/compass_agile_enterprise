class PhoneNumberObserver < ActiveRecord::Observer
  # NOTE: updating search fact here is redundant, 
  #       Contact observer is being called via has_contact.after_save => Contact.save => ContactObserver.after_save
end