class CreateCurrencies < ActiveRecord::Migration
  def self.up
    create_table :currencies do |t|
	    t.string :name
		  t.string :definition
		  t.string :alphabetic_code
		  t.string :numeric_code
		  t.string :major_unit_symbol
		  t.string :minor_unit_symbol
		  t.string :ratio_of_minor_unit_to_major_unit
		  
		  t.datetime :introduction_date
		  t.datetime :expiration_date
      t.timestamps
    end
  end

  def self.down
    drop_table :currencies
  end
  
  ## NLB TODO add indexes? 
end
