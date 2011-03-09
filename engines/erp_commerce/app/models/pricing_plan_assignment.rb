class PricingPlanAssignment < ActiveRecord::Base
  
  belongs_to  :pricing_plan
  belongs_to  :priceable_item, :polymorphic => true
  
end
