class AddPaymentGatewayTxnIdToOrderTxns < ActiveRecord::Migration
  def self.up
    unless columns(:order_txns).collect {|c| c.name}.include?('payment_gateway_txn_id')
      add_column :order_txns, :payment_gateway_txn_id, :string
    end
  end

  def self.down
    remove_column :order_txns, :payment_gateway_txn_id
  end
end
