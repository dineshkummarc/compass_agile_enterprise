class BaseErpServicesIndexes < ActiveRecord::Migration
  def self.up
    add_index :parties, [:business_party_id, :business_party_type], :name => "besi_1"
    
    add_index :categories, [:category_record_id, :category_record_type], :name => "category_polymorphic"
    add_index :category_classifications, [:classification_id, :classification_type], :name => "classification_polymorphic"

    add_index :party_roles, :party_id
    add_index :party_roles, :role_type_id    
        
    add_index :relationship_types, :valid_from_role_type_id
    add_index :relationship_types, :valid_to_role_type_id
    
    add_index :party_relationships, :status_type_id
    add_index :party_relationships, :priority_type_id
    add_index :party_relationships, :relationship_type_id
    
    add_index :individuals, :party_id 
    
    add_index :contacts, :party_id
    add_index :contacts, [:contact_mechanism_id, :contact_mechanism_type], :name => "besi_2"
    
    add_index :contact_types, :parent_id
    
    add_index :contact_purposes, :parent_id
    
    add_index :contact_purposes_contacts, [:contact_id, :contact_purpose_id], :name => "contact_purposes_contacts_index"
    
    add_index :postal_addresses, :geo_country_id
    add_index :postal_addresses, :geo_zone_id
    
    #add_index :party_search_facts, :party_id
        
    add_index :currencies_locales, :currency_id
    add_index :currencies_locales, [:locale_id, :locale_type], :name => "besi_3"
    
    ### Conditional checks: since these columns may have been added with a later migration,
    ### we check that the column exists before adding an index on it.
    
    if table_exists?(:money)
      add_index :money, :currency_id
    end
    
    if columns(:currencies).collect {|c| c.name}.include?('internal_identifier')
      add_index :currencies, :internal_identifier
    end
    
  end

  def self.down
    remove_index :categories, :name => "category_polymorphic"
    remove_index :category_classifications, :name => "classification_polymorphic"

    remove_index :parties, :name => "besi_1"
    
    remove_index :users, :party_id
    
    remove_index :party_roles, :party_id
    remove_index :party_roles, :role_type_id    
        
    remove_index :relationship_types, :valid_from_role_type_id
    remove_index :relationship_types, :valid_to_role_type_id

    remove_index :party_relationships, :status_type_id
    remove_index :party_relationships, :priority_type_id
    remove_index :party_relationships, :relationship_type_id
    
    remove_index :individuals, :party_id 
    
    remove_index :contacts, :party_id
    remove_index :contacts, :contact_purpose_id
    remove_index :contacts, :name => "besi_2"
    
    remove_index :contact_types, :parent_id
    
    remove_index :contact_purposes, :parent_id
    
    remove_index :postal_addresses, :geo_country_id
    remove_index :postal_addresses, :geo_zone_id
    
    remove_index :party_search_facts, :party_id
    
    remove_index :currencies_locales, :currency_id
    remove_index :currencies_locales, :name => "besi_3"

    ### Conditional checks: since these columns were originally added in a later
    ### migration that may not yet have already been run,
    ### we check that the column exists before removing an index on it.
    
    if table_exists?(:money)
      # money was renamed from money_amounts
      remove_index :money, :currency_id
    end
    if indexes(:currencies).collect {|i| i.name}.include?('index_currencies_on_internal_identifier')
      remove_index :currencies, :internal_identifier
    end
      
  end
end
