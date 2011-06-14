class ProductType < ActiveRecord::Base

  acts_as_nested_set
  acts_as_priceable
  has_file_assets
  is_describable
  
  include TechServices::Utils::DefaultNestedSetMethods

	belongs_to :product_type_record, :polymorphic => true  
  has_one    :product_instance

  def prod_type_relns_to
    ProdTypeReln.find(:all, :conditions => ['prod_type_id_to = ?',id])
  end

  def prod_type_relns_from
    ProdTypeReln.find(:all, :conditions => ['prod_type_id_from = ?',id])
  end
  
  def clear_all_but_this_default_list_image_flags(entity_content_assn)
    self.entity_content_assignments.each do |eca|
      if entity_content_assn.id != eca.id 
        eca.default_list_image_flag = 0 
        eca.save
      end
    end
  end

  def images_path
    File.join(RAILS_ROOT,'public/products/images',"#{self.description.underscore}_#{self.id}")
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
