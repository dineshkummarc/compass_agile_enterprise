class ProductRoleTypes
  
  def self.up
    ProdTypeRelnType.create(:internal_identifier => 'product_type_package_reln', :description => 'Product Type Package Relationship')
    ProdTypeRoleType.create(:internal_identifier => 'product_type_package', :description => 'Product Type Package')
    ProdTypeRoleType.create(:internal_identifier => 'packaged_product_type', :description => 'Packaged Product Type')

    ProdInstanceRelnType.create(:internal_identifier => 'product_instance_package_reln', :description => 'Product Instance Package Relantionship')
    ProdInstanceRoleType.create(:internal_identifier => 'product_instance_package', :description => 'Product Instance Package')
    ProdInstanceRoleType.create(:internal_identifier => 'packaged_product_instance', :description => 'Packaged Product Instance')
  end
  
  def self.down
   ['product_type_package_reln','product_type_package','packaged_product_type'].each do |iid|
     ProdTypeRelnType.iid(iid).destroy
   end

    ['product_instance_package_reln','product_instance_package','packaged_product_instance'].each do |iid|
     ProdInstanceRoleType.iid(iid).destroy
   end
  end

end
