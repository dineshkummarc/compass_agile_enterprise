class SimpleProductOffer < ActiveRecord::Base
  
  include ErpServices::Products::ActsAsProductOffer
  acts_as_product_offer
  belongs_to :product
  
#*************************************************************************
# The simplest subtype of ProductOffer. It merely points to a product
# and an offer price. Same price, same UOM for all customers on all
# channels. It can also be used for scenarios where the offer price
# and terms where calculated outside CompassERP and there is not 
# a need to duplicate the calculation. All offers have the ability to
# reference an external entity or calculation for this purpose. 
#************************************************************************* 
  
end
