class InventoryEntry < ActiveRecord::Base

	belongs_to :inventory_entry_record, :polymorphic => true 
	belongs_to :product_type
	has_one  :classification, :as => :classification, :class_name => 'CategoryClassification'
	has_many :prod_instance_inv_entries
	has_many :product_instances, :through => :prod_instance_inv_entries
	 
  def to_label
    "#{description}"
  end
  
end
