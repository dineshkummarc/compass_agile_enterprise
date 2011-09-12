class AddDefaultProdAvailTypes
  
  def self.up
    ProdAvailabilityStatusType.create(
      :description => 'Available',
      :internal_identifier => 'available'
    )

    ProdAvailabilityStatusType.create(
      :description => 'Sold',
      :internal_identifier => 'sold'
    )

    ProdAvailabilityStatusType.create(
      :description => 'Shipped',
      :internal_identifier => 'shipped'
    )
  end
  
  def self.down
    %w(available sold shipped).each do |iid|
      ProdAvailabilityStatusType.find_by_internal_identifier(iid).destroy
    end
  end

end
