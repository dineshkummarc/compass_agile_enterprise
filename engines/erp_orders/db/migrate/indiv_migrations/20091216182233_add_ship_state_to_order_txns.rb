class AddShipStateToOrderTxns < ActiveRecord::Migration

  def self.up
    add_column :order_txns, :ship_to_state, :string
  end

  def self.down
    remove_column :order_txns, :ship_to_state
  end

end
