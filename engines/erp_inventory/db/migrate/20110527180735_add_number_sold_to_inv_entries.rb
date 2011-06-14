class AddNumberSoldToInvEntries < ActiveRecord::Migration
  def self.up
    unless columns(:inventory_entries).collect {|c| c.name}.include?('number_sold')
      add_column :inventory_entries, :number_sold, :integer
    end
  end

  def self.down
    if columns(:inventory_entries).collect {|c| c.name}.include?('number_sold')
      remove_column :inventory_entries, :number_sold
    end
  end
end
