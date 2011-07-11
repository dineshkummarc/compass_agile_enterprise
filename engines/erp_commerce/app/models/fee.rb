class Fee < ActiveRecord::Base

	belongs_to  :fee_record, :polymorphic => true
  belongs_to  :money, :class_name => "ErpBaseErpSvcs::Money"
  belongs_to  :fee_type
  
end
