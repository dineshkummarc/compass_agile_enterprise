class ProductType < ActiveRecord::Base

  acts_as_nested_set
  acts_as_priceable
  
  include TechServices::Utils::DefaultNestedSetMethods

	belongs_to :product_type_record, :polymorphic => true  
  has_many   :entity_content_assignments, :as => :da_assignment, :dependent => :destroy
  has_one    :product_instance

  def prod_type_relns_to
    ProdTypeReln.find(:all, :conditions => ['prod_type_id_to = ?',id])
  end

  def prod_type_relns_from
    ProdTypeReln.find(:all, :conditions => ['prod_type_id_from = ?',id])
  end

  def images
    entity_content_assignments.collect do |eca|
      da = eca.content_mgt_asset.digital_asset
      if da.is_a?(ImageAsset)
        da
      end
    end
  end
  
  def clear_all_but_this_default_list_image_flags(entity_content_assn)
    self.entity_content_assignments.each do |eca|
      if entity_content_assn.id != eca.id 
        eca.default_list_image_flag = 0 
        eca.save
      end
    end
  end
 
  def to_label
    "#{description}"
  end
  
  def to_s
    "#{description}"
  end

  def self.count_by_status(product_type, prod_availability_status_type)
    ProductInstance.count(:conditions => ['product_type_id = ? and prod_availability_status_type_id = ?', product_type.id, prod_availability_status_type.id])
  end
  
end
