class PriceComponent < ActiveRecord::Base
  
  belongs_to  :priced_component, :polymorphic => true
  belongs_to  :pricing_plan_component
  belongs_to  :price
  belongs_to  :money
  
end
