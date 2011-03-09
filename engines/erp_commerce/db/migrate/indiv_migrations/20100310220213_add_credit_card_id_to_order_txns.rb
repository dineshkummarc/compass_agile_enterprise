class AddCreditCardIdToOrderTxns < ActiveRecord::Migration
  def self.up
    unless columns(:order_txns).collect {|c| c.name}.include?('credit_card_id')
      add_column :order_txns, :credit_card_id, :integer
    end
  end

  def self.down
    remove_column :order_txns, :credit_card_id
  end
end
