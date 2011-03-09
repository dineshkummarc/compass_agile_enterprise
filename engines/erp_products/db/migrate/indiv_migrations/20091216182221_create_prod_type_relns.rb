class CreateProdTypeRelns < ActiveRecord::Migration
  def self.up
    create_table :prod_type_relns do |t|

      t.column  :prod_type_reln_type_id, :integer
      t.column  :description, :string 
      
      t.column  :prod_type_id_from, :integer
      t.column  :prod_type_id_to, :integer

      t.column  :role_type_id_from, :integer
      t.column  :role_type_id_to, :integer

      t.column  :status_type_id, :integer
      t.column  :from_date, :date
      t.column  :thru_date, :date 

      t.timestamps
    end
  end

  def self.down
    drop_table :prod_type_relns
  end
end
