class Price < ActiveRecord::Base
  
  belongs_to  :pricing_plan
  belongs_to  :priced_item, :polymorphic => true
  has_many    :price_components, :dependent => :destroy
  belongs_to  :money, :class_name => "ErpBaseErpSvcs::Money"

  alias :components :price_components

  def get_price_components_by_type(type_iid)
    self.price_components.select{|pc| pc.pricing_plan_component.price_component_type.internal_identifier == type_iid}
  end

  def get_total_by_type(type_iid)
    total = 0
    
    components = self.price_components.select{|pc| pc.pricing_plan_component.price_component_type.internal_identifier == type_iid}
    components.each do |component|
      total = total + component.money.amount
    end

    total
  end
  
end
