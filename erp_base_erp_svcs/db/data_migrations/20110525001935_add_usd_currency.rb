class AddUsdCurrency
  
  def self.up
    Currency.create(:name => 'US Dollar', :internal_identifier => 'USD', :major_unit_symbol => "$")
  end
  
  def self.down
    Currency.usd.destroy
  end

end
