class CreateCreditCardAccounts < ActiveRecord::Migration
  def self.up
    create_table :credit_card_accounts do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :credit_card_accounts
  end
end
