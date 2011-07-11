class PricingPlanComponent < ActiveRecord::Base

  #these relationships essentially mean that pricing plan components can
  #be shared across pricing plan. This is accomplished by using a cross-reference
  #table called 'valid_price_plan_components'
  has_many   :valid_price_plan_components
  has_many   :pricing_plans, :through => :valid_price_plan_components
  belongs_to :price_component_type
  belongs_to :currency, :class_name => 'ErpBaseErpSvcs::Currency'
  
  def get_price_component( rule_ctx = nil )
    
    #this will be relaced by an execution of the stored 'matching_rule' and 'pricing_calculation' 
    #although it might make sense to have an 'is_simple' flag and corresponding value so the price 
    #component can simply create one price component with one float value without invoking a rules
    #engine or the interpreter

    if self.is_simple_amount
      component_amount = self.money_amount
    else
      component_amount = eval(self.pricing_calculation)
    end

    money = ErpBaseErpSvcs::Money.new(:description => self.description, :amount => component_amount, :currency => self.currency)

    price_component = PriceComponent.new(
      :money => money,
      :pricing_plan_component => self,
      :description => self.description
    )

    price_component
    
  end  
  
end
