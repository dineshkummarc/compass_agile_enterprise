class AddOrderNumToOrderTxns < ActiveRecord::Migration

  def self.up
    add_column :order_txns, :order_number, :integer
  end

  def self.down
    remove_column :order_txns, :order_number
  end

end
