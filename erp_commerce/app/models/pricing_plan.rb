class PricingPlan < ActiveRecord::Base

  has_many   :valid_price_plan_components
  has_many   :pricing_plan_components, :through => :valid_price_plan_components
  belongs_to :currency
  
  alias :components :pricing_plan_components

  def get_price( rule_ctx = nil ) 
        
    price = Price.new
    price.pricing_plan = self

    #first check if this is a simple amount if so get the amount.
    if self.is_simple_amount
      price.money = Money.new(:amount => self.money_amount, :currency => self.currency)

    #second check if a pricing calculation exists if so use it.
    elsif !self.pricing_calculation.nil?
      rule_ctx[:pricing_plan] = self
      rule_ctx[:price] = price
      eval(self.pricing_calculation)

    #finanlly if this is not a simple amount and has no pricing calcuation use the price components associated to this plan
    else
      self.pricing_plan_components.each do |pricing_plan_component|
        price_component = pricing_plan_component.get_price_component(rule_ctx)
        price.components << price_component
      end
    end

    price.description = self.description

    price
  end

end
