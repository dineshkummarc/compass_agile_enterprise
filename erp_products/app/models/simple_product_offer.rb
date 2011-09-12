class SimpleProductOffer < ActiveRecord::Base
  acts_as_product_offer
  belongs_to :product
end
