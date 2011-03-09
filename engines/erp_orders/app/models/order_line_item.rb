class OrderLineItem < ActiveRecord::Base

	belongs_to :order_txn, :class_name => 'OrderTxn'
	belongs_to :order_line_item_type
	
  has_many :charge_lines, :as => :charged_item

  belongs_to :product_instance
  belongs_to :product_type
end
