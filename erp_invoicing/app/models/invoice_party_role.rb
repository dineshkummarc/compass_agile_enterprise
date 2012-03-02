class InvoicePartyRole < ActiveRecord::Base

  belongs_to  :invoice
  belongs_to  :party
  belongs_to  :role_type  

end
