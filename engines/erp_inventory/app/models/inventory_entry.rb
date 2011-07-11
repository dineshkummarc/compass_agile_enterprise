class InventoryEntry < ActiveRecord::Base

	belongs_to :inventory_entry_record, :polymorphic => true
	belongs_to :product_type
	has_one  :classification, :as => :classification, :class_name => 'CategoryClassification'
	has_many :prod_instance_inv_entries
	has_many :product_instances, :through => :prod_instance_inv_entries do
    def available
      find(:all,
        :include => [:prod_availability_status_type],
        :conditions => ['prod_availability_status_types.internal_identifier = ?', 'available'])
    end

    def sold
      find(:all,
        :include => [:prod_availability_status_type],
        :conditions => ['prod_availability_status_types.internal_identifier = ?', 'sold'])
    end
  end
	 
  def to_label
    "#{description}"
  end

end
