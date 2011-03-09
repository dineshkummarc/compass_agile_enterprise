class RenameOrdertxnCountryColumns < ActiveRecord::Migration
  def self.up
  	unless columns(:order_txns).collect {|c| c.name}.include?('bill_to_country_name')
  	  rename_column :order_txns, :bill_to_country, :bill_to_country_name
  	  rename_column :order_txns, :ship_to_country, :ship_to_country_name
      add_column :order_txns, :bill_to_country, :string
      add_column :order_txns, :ship_to_country, :string
    end
  end

  def self.down
    unless !columns(:order_txns).collect {|c| c.name}.include?('bill_to_country_name')
      remove_column :order_txns, :bill_to_country
      remove_column :order_txns, :ship_to_country
      rename_column :order_txns, :bill_to_country_name, :bill_to_country
  	  rename_column :order_txns, :ship_to_country_name, :ship_to_country
	  end
  end
end
