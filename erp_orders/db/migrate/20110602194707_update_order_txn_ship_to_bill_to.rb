class UpdateOrderTxnShipToBillTo < ActiveRecord::Migration
  def self.up
    unless columns(:order_txns).collect {|c| c.name}.include?('bill_to_address_line_1')
      rename_column :order_txns, :bill_to_address, :bill_to_address_line_1
      add_column :order_txns, :bill_to_address_line_2, :string
    end

    unless columns(:order_txns).collect {|c| c.name}.include?('ship_to_address_line_1')
      rename_column :order_txns, :ship_to_address, :ship_to_address_line_1
      add_column :order_txns, :ship_to_address_line_2, :string
    end
  end

  def self.down
    if columns(:order_txns).collect {|c| c.name}.include?('bill_to_address_line_1')
      rename_column :order_txns, :bill_to_address_line_1, :bill_to_address
      remove_column :order_txns, :bill_to_address_line_2
    end

    if columns(:order_txns).collect {|c| c.name}.include?('ship_to_address_line_1')
      rename_column :order_txns, :ship_to_address_line_1, :ship_to_address
      remove_column :order_txns, :ship_to_address_line_2
    end
  end
end
