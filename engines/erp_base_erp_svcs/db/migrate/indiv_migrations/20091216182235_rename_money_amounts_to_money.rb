class RenameMoneyAmountsToMoney < ActiveRecord::Migration
  def self.up
    rename_table :money_amounts, :money
  end

  def self.down
    rename_table :money, :money_amounts
  end
end
