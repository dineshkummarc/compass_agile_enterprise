class UpdateCurrencies < ActiveRecord::Migration
  def self.up
    rename_column :currencies, :alphabetic_code, :internal_identifier
    add_column :currencies, :postfix_label, :string
  end

  def self.down
    remove_column :currencies, :postfix_label
    rename_column :currencies, :internal_identifier, :alphabetic_code
  end
end
