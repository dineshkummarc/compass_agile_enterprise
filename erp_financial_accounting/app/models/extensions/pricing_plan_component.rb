PricingPlanComponent.class_eval do
  
  has_many  :price_plan_comp_gl_accounts
  has_many  :gl_accounts, :through => :price_plan_comp_gl_accounts
  
  def map_to_gl_accounts
    
    puts "Please implement this method to map pricing plan components to gl accounts"
    puts "Find me in [RAILS_ROOT/plugins/erp_financial_accounting/models/extensions/pricing_plan_component.rb]"
    puts "******"
    
    if self.gl_accounts.count > 0
      puts "Linked GL Account list"
      puts "******"
    
      self.gl_accounts.each do |acct|
        puts acct.description
      end
      puts "******"
    else
      puts "There are no GL accounts mapped to this pricing plan component"
    end
    return self
  end
  
end