class PriceComponentType < ActiveRecord::Base
  has_many :pricing_plan_components
end
