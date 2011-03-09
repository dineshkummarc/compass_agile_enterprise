class CreateCreditCards < ActiveRecord::Migration
  def self.up
    create_table :credit_cards do |t|

      t.column :crypted_private_card_number,  :string
      t.column :expiration_month,             :integer     
      t.column :expiration_year,              :integer

      t.column :description,                  :string
      t.column :first_name_on_card,           :string
      t.column :last_name_on_card,            :string
      t.column :card_type,                    :string
      
      t.column :postal_address_id,            :integer
      t.column :credit_card_account_party_role_id, :integer

      t.timestamps
    end
    
    add_index :credit_cards, :postal_address_id
    add_index :credit_cards, :credit_card_account_party_role_id
  end

  def self.down
    drop_table :credit_cards
  end
end
