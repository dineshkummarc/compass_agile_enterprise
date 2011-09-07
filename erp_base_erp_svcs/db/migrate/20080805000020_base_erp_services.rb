class BaseErpServices < ActiveRecord::Migration
  def self.up
    
    # Create parties table
    unless table_exists?(:parties)
      create_table :parties do |t|
        t.column    	:description,         :string
        t.column    	:business_party_id,   :integer
        t.column    	:business_party_type, :string
        t.column    	:list_view_image_id,  :integer
        
        #This field is here to provide a direct way to map CompassERP
        #business parties to unified idenfiers in organizations if they
        #have been implemented in an enterprise.
        t.column		:enterprise_identifier, :string
        t.timestamps
      end
      add_index :parties, [:business_party_id, :business_party_type], :name => "besi_1"
    end
    
    # Create party_roles table
    unless table_exists?(:party_roles)
      create_table :party_roles do |t|
        #this column holds the class name of the 
        #subtype of party-to-role_type relatsionship
        t.column  :type,          :string
        #xref between party and role_type      
        t.column  :party_id,      :integer
    	  t.column  :role_type_id,  :integer
    	  t.timestamps
      end
	  add_index :party_roles, :party_id
	  add_index :party_roles, :role_type_id 
    end
    
    
    # Create role_types table
    unless table_exists?(:role_types)
      create_table :role_types do |t|
        #these columns are required to support the behavior of the plugin 'better_nested_set'
        t.column  	:parent_id,    :integer
        t.column  	:lft,          :integer
        t.column  	:rgt,          :integer

        #custom columns go here   
        t.column     :description,         :string
        t.column     :comments,            :string
		    t.column 	   :internal_identifier, :string
		    t.column 	   :external_identifier, :string
		    t.column 	   :external_id_source,  :string
        t.timestamps
      end
    end
    
    # Create relationship_types table
    unless table_exists?(:relationship_types)
      create_table :relationship_types do |t|
        t.column  	:parent_id,    :integer
        t.column  	:lft,          :integer
        t.column  	:rgt,          :integer

        #custom columns go here        
        t.column  	:valid_from_role_type_id, :integer
        t.column  	:valid_to_role_type_id,   :integer
        t.column  	:name,                    :string  
        t.column  	:description,             :string

		t.column    :internal_identifier, 	  :string
		t.column    :external_identifier, 	  :string
	    t.column    :external_id_source,      :string
        t.timestamps
      end
	  add_index :relationship_types, :valid_from_role_type_id
	  add_index :relationship_types, :valid_to_role_type_id
    end
    
    # Create party_relationships table
    unless table_exists?(:party_relationships)
      create_table :party_relationships do |t|
        t.column    :description,           :string 
        t.column    :party_id_from,         :integer
        t.column    :party_id_to,           :integer
        t.column    :role_type_id_from,     :integer
        t.column    :role_type_id_to,       :integer
        t.column    :status_type_id,        :integer
        t.column    :priority_type_id,      :integer
        t.column    :relationship_type_id,  :integer
        t.column    :from_date,             :date
        t.column    :thru_date,             :date   
		    t.column    :external_identifier, 	:string
		    t.column    :external_id_source,    :string
      	t.timestamps
      end
	  add_index :party_relationships, :status_type_id
      add_index :party_relationships, :priority_type_id
      add_index :party_relationships, :relationship_type_id
    end
    
    # Create organizations table
    unless table_exists?(:organizations)
      create_table :organizations do |t|
		    t.column    :description,   :string
		    t.column  	:tax_id_number, :string
		    t.timestamps
      end
    end
    
    # Create individuals table 
    unless table_exists?(:individuals)
      create_table :individuals do |t|
		    t.column  :party_id,                :integer
		    t.column  :current_last_name,       :string
		    t.column  :current_first_name,      :string
		    t.column  :current_middle_name,     :string
		    t.column  :current_personal_title,  :string
		    t.column  :current_suffix,          :string
		    t.column  :current_nickname,        :string
		    t.column  :gender,                  :string,  :limit => 1
		    t.column  :birth_date,              :date
		    t.column  :height,                  :decimal, :precision => 5, :scale => 2
		    t.column  :weight,                  :integer
		    t.column  :mothers_maiden_name,     :string
		    t.column  :marital_status,          :string,  :limit => 1
		    t.column  :social_security_number,  :string
		    t.column  :current_passport_number, :integer
		    
		    t.column  :current_passport_expire_date,  :date
		    t.column  :total_years_work_experience,   :integer
		    t.column  :comments,                      :string
		    t.column  :encrypted_ssn,                 :string  	
			t.column  :temp_ssn,                      :string 
			t.column  :salt,                          :string
			t.column  :ssn_last_four,                 :string 
		    t.timestamps
      end
	  add_index :individuals, :party_id
    end
    
    # Create contacts table
    unless table_exists?(:contacts)
      create_table :contacts do |t|
        t.column    :party_id,                :integer
        t.column    :contact_mechanism_id,    :integer
        t.column    :contact_mechanism_type,  :string
        
        t.column 	:external_identifier,       :string
        t.column 	:external_id_source, 	      :string

        t.timestamps
      end
	  add_index :contacts, :party_id
	  add_index :contacts, [:contact_mechanism_id, :contact_mechanism_type], :name => "besi_2"
    end
    
    # Create contact_types
    unless table_exists?(:contact_types)
      create_table :contact_types do |t|
        t.column  :parent_id,    :integer
        t.column  :lft,          :integer
        t.column  :rgt,          :integer

        #custom columns go here   

        t.column  :description,         :string
        t.column  :comments,            :string

		    t.column 	:internal_identifier, :string
		    t.column 	:external_identifier, :string
		    t.column 	:external_id_source, 	:string

        t.timestamps
      end
	  add_index :contact_types, :parent_id
    end
    
    # Create contact_purposes
    unless table_exists?(:contact_purposes)
      create_table :contact_purposes do |t|

      	t.column  :parent_id,    :integer
      	t.column  :lft,          :integer
      	t.column  :rgt,          :integer

        #custom columns go here   

      	t.column  :description,         :string
      	t.column  :comments,            :string

		    t.column 	:internal_identifier, :string
		    t.column 	:external_identifier, :string
		    t.column 	:external_id_source, 	:string

        t.timestamps
      end
	    add_index :contact_purposes, :parent_id
      
    end
    
    unless table_exists?(:contact_purposes_contacts)
        create_table :contact_purposes_contacts, {:id => false} do |t|
          t.column :contact_id,         :integer
          t.column :contact_purpose_id, :integer
        end
        add_index :contact_purposes_contacts, [:contact_id, :contact_purpose_id], :name => "contact_purposes_contacts_index"
    end
    
    # Create postal_addresses (a contact_mechanism)
    unless table_exists?(:postal_addresses)
      create_table :postal_addresses do |t|
		    t.column    :address_line_1,    :string
		    t.column    :address_line_2,    :string
		    t.column    :city,              :string
		    t.column    :state,             :string
		    t.column    :zip,               :string
		    t.column    :country,           :string
		    t.column    :description,       :string
		    t.column    :geo_country_id,    :integer
		    t.column    :geo_zone_id,       :integer
		    t.timestamps
      end
	  add_index :postal_addresses, :geo_country_id
	  add_index :postal_addresses, :geo_zone_id
    end
    
    # Create email_addresses (a contact_mechanism)
    unless table_exists?(:email_addresses)
	    create_table :email_addresses do |t|
		  	t.column    :email_address,     	:string
		  	t.column    :description,       	:string
		  	
		  	t.timestamps
	    end
    end
    
    # Create phone_numbers table (A contact_mechanism)
    unless table_exists?(:phone_numbers)
      create_table :phone_numbers do |t|
			  t.column    :phone_number,  		:string
			  t.column    :description,       :string

        t.timestamps
      end
    end
    
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
    
    unless table_exists?(:money)
      create_table :money do |t|
        t.string      :description
        t.float       :amount
        t.references  :currency 
        t.timestamps
      end
	  add_index :money, :currency_id
    end

    unless table_exists?(:currencies)
      create_table :currencies do |t|
	      t.string    :name
		    t.string    :definition
		    t.string    :internal_identifier # aka alphabetic_code
		    t.string    :numeric_code
		    t.string    :major_unit_symbol
		    t.string    :minor_unit_symbol
		    t.string    :ratio_of_minor_unit_to_major_unit
		    t.string    :postfix_label
		    t.datetime  :introduction_date
		    t.datetime  :expiration_date
        t.timestamps
      end
	  add_index :currencies, :internal_identifier
    end
    
    unless table_exists?(:currencies_locales)
      create_table :currencies_locales do |t|
        t.references :currency
        t.references :locale, :polymorphic => true
        t.timestamps
      end
	  add_index :currencies_locales, :currency_id
      add_index :currencies_locales, [:locale_id, :locale_type], :name => "besi_3"
    end

    ## categories
    unless table_exists?(:categories)
      create_table :categories do |t|
        t.string :description
        t.string :external_identifier
        t.datetime :from_date
        t.datetime :to_date
        t.string :internal_identifier

        # polymorphic assns
        t.integer :category_record_id
        t.string  :category_record_type

        # nested set cols
        t.integer :parent_id
        t.integer :lft
        t.integer :rgt

        t.timestamps
      end
	  add_index :categories, [:category_record_id, :category_record_type], :name => "category_polymorphic"
    end

    ## category_classifications
    unless table_exists?(:category_classifications)
      create_table :category_classifications do |t|
        t.integer  :category_id
        t.string   :classification_type
        t.integer  :classification_id
        t.datetime :from_date
        t.datetime :to_date

        t.timestamps
      end
	  add_index :category_classifications, [:classification_id, :classification_type], :name => "classification_polymorphic"
    end

    ## descriptive_assets
    unless table_exists?(:descriptive_assets)
      create_table :descriptive_assets do |t|
        t.references :view_type
        t.string     :internal_identifier
        t.text       :description
        t.string     :external_identifier
        t.string     :external_id_source
        t.references :described_record, :polymorphic => true

        t.timestamps
      end

      add_index :descriptive_assets, :view_type_id
      add_index :descriptive_assets, [:described_record_id, :described_record_type], :name => 'described_record_idx'
    end

    unless table_exists?(:view_types)
      create_table :view_types do |t|
        t.string     :internal_identifier
        t.string     :description

        t.timestamps
      end
    end

    unless table_exists?(:geo_countries)
      create_table :geo_countries do |t|
        t.column :name,         :string
        t.column :iso_code_2,   :string,  :length => 2
        t.column :iso_code_3,   :string,  :length => 3
        t.column :display,      :boolean, :default => true
        t.column :external_id,  :integer
        t.column :created_at,   :datetime
      end
	  add_index :geo_countries, :name
      add_index :geo_countries, :iso_code_2
    end

    unless table_exists?(:geo_zones)
      create_table :geo_zones do |t|
        t.column :geo_country_id, :integer
        t.column :zone_code,      :string,  :default => 2
        t.column :zone_name,      :string
        t.column :created_at,     :datetime
      end
	  add_index :geo_zones, :geo_country_id
      add_index :geo_zones, :zone_name
      add_index :geo_zones, :zone_code
    end

    unless table_exists?(:notes)
      create_table   :notes do |t|
        t.integer    :created_by_id
        t.text       :content
        t.references :noted_record, :polymorphic => true
        t.references :note_type

        t.timestamps
      end

      add_index :notes, [:noted_record_id, :noted_record_type]
      add_index :notes, :note_type_id
      add_index :notes, :created_by_id
      add_index :notes, :content
    end

    unless table_exists?(:note_types)
      create_table :note_types do |t|
        #these columns are required to support the behavior of the plugin 'awesome_nested_set'
        t.integer  	:parent_id
        t.integer  	:lft
        t.integer  	:rgt

        t.string     :description
        t.string     :internal_identifier
        t.string     :external_identifier
        t.references :note_type_record, :polymorphic => true

        t.timestamps
      end

      add_index :note_types, [:note_type_record_id, :note_type_record_type], :name => "note_type_record_idx"
    end
    
    unless table_exists?(:valid_note_types)
      create_table   :valid_note_types do |t|
        t.references :valid_note_type_record, :polymorphic => true
        t.references :note_type
    
        t.timestamps
      end

      add_index :valid_note_types, [:valid_note_type_record_id, :valid_note_type_record_type], :name => "valid_note_type_record_idx"
      add_index :valid_note_types, :note_type_id
    end

  end

  def self.down
    [
      :currencies_locales, :currencies, :money,
      :party_search_facts, :phone_numbers, :email_addresses, 
      :postal_addresses, :contact_purposes, :contact_types,
      :contacts, :individuals, :organizations, 
      :party_relationships, :relationship_types, :role_types, 
      :party_roles, :parties, :categories, :category_classifications,
      :descriptive_assets, :view_types, :notes, :note_types, :valid_note_types
    ].each do |tbl|
      if table_exists?(tbl)
        drop_table tbl
      end
    end

  end
end
