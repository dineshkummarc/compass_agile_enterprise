class RecreatePartySearchFactsTable < ActiveRecord::Migration
  def self.up
    drop_table :party_search_facts if table_exists?(:party_search_facts)
    
    unless table_exists?(:party_search_facts)
      create_table :party_search_facts do |t|
        t.column :party_id,                       :integer
        t.column :eid,                            :string
        t.column :type,                           :string
        t.column :roles,                          :text
        t.column :party_description,              :string
        t.column :party_business_party_type,      :string
        t.column :user_login,                     :string
        t.column :individual_current_last_name,   :string
        t.column :individual_current_first_name,  :string
        t.column :individual_current_middle_name, :string
        t.column :individual_birth_date,          :string
        t.column :individual_ssn,                 :string
        t.column :party_phone_number,             :string
        t.column :party_email_address,            :string
        t.column :party_address_1,                :string
        t.column :party_address_2,                :string
        t.column :party_primary_address_city,     :string
        t.column :party_primary_address_state,    :string
        t.column :party_primary_address_zip,      :string
        t.column :party_primary_address_country,  :string
        t.column :user_enabled,                   :boolean
        t.column :user_type,                      :string
        t.column :reindex,                        :boolean
            
        t.timestamps
      end
    end
  end

  def self.down  
    drop_table :party_search_facts if table_exists?(:party_search_facts)
  end
end
