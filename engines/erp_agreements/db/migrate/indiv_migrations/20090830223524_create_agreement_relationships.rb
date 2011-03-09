class CreateAgreementRelationships < ActiveRecord::Migration
  def self.up
    create_table :agreement_relationships do |t|

      t.column  :agreement_reln_type_id, :integer
      t.column  :description, :string 
      
      t.column  :agreement_id_from, :integer
      t.column  :agreement_id_to, :integer

      t.column  :role_type_id_from, :integer
      t.column  :role_type_id_to, :integer

      t.column  :status_type_id, :integer
      t.column  :from_date, :date
      t.column  :thru_date, :date 

      t.timestamps

    end
  end

  def self.down
    drop_table :agreement_relationships
  end
end
