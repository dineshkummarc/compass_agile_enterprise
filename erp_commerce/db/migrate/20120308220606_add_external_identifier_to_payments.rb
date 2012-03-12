class AddExternalIdentifierToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :external_identifier, :string
  end
end
