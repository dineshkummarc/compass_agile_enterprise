class CreateAgreementPartyRoles < ActiveRecord::Migration
  def self.up
    create_table :agreement_party_roles do |t|

      t.column  :description,   	:string 
      
      t.column  :agreement_id,     	:integer  
      t.column  :party_id,         	:integer    
      t.column  :role_type_id,     	:integer
      t.column  :external_identifier, :string
      t.column  :external_id_source,  :string
      t.timestamps

    end
  end

  def self.down
    drop_table :agreement_party_roles
  end
end
