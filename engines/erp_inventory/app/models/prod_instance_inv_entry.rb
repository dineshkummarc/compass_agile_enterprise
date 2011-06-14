class ProdInstanceInvEntry < ActiveRecord::Base
  
  belongs_to :product_instance
  belongs_to :inventory_entry
  
end
