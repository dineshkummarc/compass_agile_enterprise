class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|

      t.column    :party_id,    :integer
      t.column    :contact_purpose_id,    :integer
      t.column    :contact_mechanism_id,    :integer
      t.column    :contact_mechanism_type,  :string
      
      t.column 	:external_identifier, 	:string
      t.column 	:external_id_source, 	:string

      t.timestamps

    end
  end

  def self.down	
  	drop_table :contacts
  end
end
