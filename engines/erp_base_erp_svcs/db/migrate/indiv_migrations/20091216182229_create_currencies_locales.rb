class CreateCurrenciesLocales < ActiveRecord::Migration
  def self.up
    create_table :currencies_locales do |t|

      t.references :currency
      t.references :locale, :polymorphic => true
      
      t.timestamps
    end
  end

  def self.down
    drop_table :currencies_locales
  end
end
