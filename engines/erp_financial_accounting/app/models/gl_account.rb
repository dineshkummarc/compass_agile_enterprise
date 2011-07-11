class GlAccount < ActiveRecord::Base

  acts_as_nested_set
  acts_as_mdm_entity  
  
  has_many  :price_plan_comp_gl_accounts
  has_many  :pricing_plan_components, :through => :price_plan_comp_gl_accounts
   
end
