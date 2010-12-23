class CreatePartyRelationships < ActiveRecord::Migration
  def self.up
    create_table :party_relationships do |t|

        t.column    :description, :string 
        t.column    :party_id_from, :integer
        t.column    :party_id_to, :integer
        t.column    :role_type_id_from, :integer
        t.column    :role_type_id_to, :integer
        t.column    :status_type_id, :integer
        t.column    :priority_type_id, :integer
        t.column    :relationship_type_id, :integer
        t.column    :from_date, :date
        t.column    :thru_date, :date   

		t.column 	:external_identifier, 	:string
		t.column 	:external_id_source, 	:string

      	t.timestamps

    end
  end

  def self.down
    drop_table :party_relationships
  end
end
