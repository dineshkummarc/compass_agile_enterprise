class CreateCreditCardAccountPartyRoles < ActiveRecord::Migration
  def self.up
    create_table :credit_card_account_party_roles do |t|
      t.column :credit_card_account_id, :integer     
      t.column :role_type_id,           :integer
      t.column :party_id,               :integer
      
      t.timestamps
    end
    
    add_index :credit_card_account_party_roles, :credit_card_account_id
    add_index :credit_card_account_party_roles, :role_type_id
    add_index :credit_card_account_party_roles, :party_id
      
  end

  def self.down
    drop_table :credit_card_account_party_roles
  end
end
