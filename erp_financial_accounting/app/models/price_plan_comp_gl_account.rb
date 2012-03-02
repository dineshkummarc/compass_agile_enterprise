class PricePlanCompGlAccount < ActiveRecord::Base
  belongs_to :pricing_plan_component
  belongs_to :gl_account
end
