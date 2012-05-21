class ProductType < ActiveRecord::Base
  acts_as_nested_set
  include ErpTechSvcs::Utils::DefaultNestedSetMethods
 
  has_file_assets
  is_describable
  
	belongs_to :product_type_record, :polymorphic => true  
  has_one    :product_instance
  
  def prod_type_relns_to
    ProdTypeReln.where('prod_type_id_to = ?',id)
  end

  def prod_type_relns_from
    ProdTypeReln.where('prod_type_id_from = ?',id)
  end
 
  def to_label
    "#{description}"
  end
  
  def to_s
    "#{description}"
  end

  def self.count_by_status(product_type, prod_availability_status_type)
    ProductInstance.count("product_type_id = #{product_type.id} and prod_availability_status_type_id = #{prod_availability_status_type.id}")
  end
  
  def images_path
    file_support = ErpTechSvcs::FileSupport::Base.new(:storage => Rails.application.config.erp_tech_svcs.file_storage)
    File.join(file_support.root,Rails.application.config.erp_tech_svcs.file_assets_location,'products','images',"#{self.description.underscore}_#{self.id}")
  end
  
end
