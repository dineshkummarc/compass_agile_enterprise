class CreateMoneyAmounts < ActiveRecord::Migration
  def self.up
    create_table :money_amounts do |t|

      t.string  :description
      t.float   :amount
      t.references  :currency 

      t.timestamps
    end
  end

  def self.down
    drop_table :money_amounts
  end
end
