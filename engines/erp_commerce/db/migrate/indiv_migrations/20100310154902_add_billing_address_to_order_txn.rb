class AddBillingAddressToOrderTxn < ActiveRecord::Migration
  def self.up
    unless columns(:order_txns).collect {|c| c.name}.include?('bill_to_first_name')
      add_column :order_txns, :bill_to_first_name, :string
    end
    unless columns(:order_txns).collect {|c| c.name}.include?('bill_to_last_name')
      add_column :order_txns, :bill_to_last_name, :string
    end  
    unless columns(:order_txns).collect {|c| c.name}.include?('bill_to_address')
      add_column :order_txns, :bill_to_address, :string
    end
    unless columns(:order_txns).collect {|c| c.name}.include?('bill_to_city')
      add_column :order_txns, :bill_to_city, :string
    end    
    unless columns(:order_txns).collect {|c| c.name}.include?('bill_to_state')
      add_column :order_txns, :bill_to_state, :string
    end
    unless columns(:order_txns).collect {|c| c.name}.include?('bill_to_postal_code')
      add_column :order_txns, :bill_to_postal_code, :string
    end  
    unless columns(:order_txns).collect {|c| c.name}.include?('bill_to_country')
      add_column :order_txns, :bill_to_country, :string
    end
  end

  def self.down
    remove_column :order_txns, :bill_to_first_name
    remove_column :order_txns, :bill_to_last_name
    remove_column :order_txns, :bill_to_address
    remove_column :order_txns, :bill_to_city
    remove_column :order_txns, :bill_to_state
    remove_column :order_txns, :bill_to_postal_code
    remove_column :order_txns, :bill_to_country
  end
end
