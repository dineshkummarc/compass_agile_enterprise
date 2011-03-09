class CreateChargeLines < ActiveRecord::Migration
  def self.up
    create_table :charge_lines do |t|
      
      t.string  :sti_type
      t.integer :charged_items_id
      t.string  :charged_items_type
      
      t.references :money_amount
      
      t.string :description     #could be expanded to include type information, etc.

      t.timestamps
    end
  end

  def self.down
    drop_table :charge_lines
  end
end
