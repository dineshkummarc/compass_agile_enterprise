WorkEffort.class_eval do

  #*************************************************************
  # This line of code needs to go into an extension of the any 
  # model class that is invoiceable. This includes:
  # ProductType, ProductInstance, WorkEffort, TimeEntry
  #*************************************************************  
  has_one :invoice_item, :as => :invoiceable_item
      
end