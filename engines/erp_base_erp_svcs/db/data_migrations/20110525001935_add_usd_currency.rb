class AddUsdCurrency
  
  def self.up
    ErpBaseErpSvcs::Currency.create(:name => 'US Dollar', :internal_identifier => 'USD')
  end
  
  def self.down
    ErpBaseErpSvcs::Currency.usd.destroy
  end

end
