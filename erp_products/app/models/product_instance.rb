class ProductInstance < ActiveRecord::Base
  acts_as_nested_set
  include ErpTechSvcs::Utils::DefaultNestedSetMethods
  
  belongs_to :product_type	
  belongs_to :product_instance_status_type
  belongs_to :product_instance_record, :polymorphic => true
  belongs_to :prod_availability_status_type
	
  alias :status :product_instance_status_type

  def prod_instance_relns_to
    ProdInstanceReln.where('prod_instance_id_to = ?',id)
  end
  
  def prod_instance_relns_from
    ProdInstanceReln.where('prod_instance_id_from = ?',id)
  end
  
end
