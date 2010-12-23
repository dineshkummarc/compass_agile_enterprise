class CreatePartySearchFacts < ActiveRecord::Migration
  def self.up
    create_table :party_search_facts do |t|

      
      t.column :party_id,     :integer

      t.column :eid,          :string

      t.column :description,  :string

      t.column  :username,    :string

      t.column :lastname,     :string

      t.column :firstname,    :string

      t.column :middlename,   :string

      t.column :birthdate,    :string

      t.column :ssn,          :string

      t.column :phone,        :string

      t.column :email,        :string

      t.column :addr1,        :string

      t.column :addr2,        :string

      t.column :city,         :string

      t.column :state,        :string

      t.column :zip,          :string

      t.column :country,      :string
      t.timestamps
      # customer specific columns
      # exmple: orangelake
      # These columns are now added in ol_parties_and_contacts migrations
      t.column :active,       :boolean
      t.column :owner_numbers, :string
      t.column :member_numbers, :string
      

    end
  end

  def self.down
    drop_table :party_search_facts
  end
end
