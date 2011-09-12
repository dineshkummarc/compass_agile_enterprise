class AddSkuToInventory < ActiveRecord::Migration
  def self.up
    unless columns(:inventory_entries).collect {|c| c.name}.include?('sku')
      add_column :inventory_entries, :sku, :string
    end
  end

  def self.down
    if columns(:inventory_entries).collect {|c| c.name}.include?('sku')
      remove_column :inventory_entries, :sku
    end
  end
end
