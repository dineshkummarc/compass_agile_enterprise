class PricingPlan < ActiveRecord::Base

  has_many  :valid_price_plan_components
  has_many  :pricing_plan_components, :through => :valid_price_plan_components
  
  alias :components :pricing_plan_components

  def get_price( rule_ctx = nil ) 
        
    price = Price.new
    price.pricing_plan = self

    if self.is_simple_amount
      self.pricing_plan_components.each do |pricing_plan_component|
        price_component = pricing_plan_component.get_price_component(rule_ctx)
        price_component.price = price
        price.components << price_component
      end
    else
      rule_ctx[:pricing_plan] = self
      rule_ctx[:price] = price
      eval(self.pricing_calculation)
    end



    #this should be replaced wtih an application of the pricing_calculation
    price.description = self.description
    
    return price
  end

end
