class ErpCommerceBase < ActiveRecord::Migration
  def self.up
    #tables
    unless table_exists?(:credit_cards)
     create_table :credit_cards do |t|

        t.column :crypted_private_card_number,       :string
        t.column :expiration_month,                  :integer     
        t.column :expiration_year,                   :integer

        t.column :description,                       :string
        t.column :first_name_on_card,                :string
        t.column :last_name_on_card,                 :string
        t.column :card_type,                         :string

        t.column :postal_address_id,                 :integer
        t.column :credit_card_account_party_role_id, :integer
        t.column :credit_card_account_purpose_id,    :integer
        t.column :credit_card_token,                 :string

        t.timestamps
      end
    end
    
    unless table_exists?(:credit_card_accounts)
      create_table :credit_card_accounts do |t|

        t.timestamps
      end
    end
    
    unless table_exists?(:credit_card_account_party_roles)
        create_table :credit_card_account_party_roles do |t|
          t.column :credit_card_account_id, :integer     
          t.column :role_type_id,           :integer
          t.column :party_id,               :integer

          t.timestamps
        end

        add_index :credit_card_account_party_roles, :credit_card_account_id
        add_index :credit_card_account_party_roles, :role_type_id
        add_index :credit_card_account_party_roles, :party_id
    end
      
    unless table_exists?(:credit_card_account_purposes)
          create_table :credit_card_account_purposes do |t|

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
    end
    #end tables
      
    #columns
    unless columns(:order_txns).collect {|c| c.name}.include?('payment_gateway_txn_id')
        add_column :order_txns, :payment_gateway_txn_id, :string
    end
      
    unless columns(:order_txns).collect {|c| c.name}.include?('credit_card_id')
        add_column :order_txns, :credit_card_id, :integer
    end
    
    unless columns(:order_txns).collect {|c| c.name}.include?('bill_to_first_name')
      add_column :order_txns, :bill_to_first_name, :string
    end
    
    unless columns(:order_txns).collect {|c| c.name}.include?('bill_to_last_name')
      add_column :order_txns, :bill_to_last_name, :string
    end  
    
    unless columns(:order_txns).collect {|c| c.name}.include?('bill_to_address')
      add_column :order_txns, :bill_to_address, :string
    end
    
    unless columns(:order_txns).collect {|c| c.name}.include?('bill_to_city')
      add_column :order_txns, :bill_to_city, :string
    end   
     
    unless columns(:order_txns).collect {|c| c.name}.include?('bill_to_state')
      add_column :order_txns, :bill_to_state, :string
    end
    
    unless columns(:order_txns).collect {|c| c.name}.include?('bill_to_postal_code')
      add_column :order_txns, :bill_to_postal_code, :string
    end  
    
    unless columns(:order_txns).collect {|c| c.name}.include?('bill_to_country')
      add_column :order_txns, :bill_to_country, :string
    end
    
    unless columns(:order_txns).collect {|c| c.name}.include?('bill_to_country_name')
  	  rename_column :order_txns, :bill_to_country, :bill_to_country_name
  	  rename_column :order_txns, :ship_to_country, :ship_to_country_name
      add_column :order_txns, :bill_to_country, :string
      add_column :order_txns, :ship_to_country, :string
    end
    #end
  end

  def self.down
    
    if columns(:order_txns).collect {|c| c.name}.include?('payment_gateway_txn_id')
      remove_column :order_txns, :payment_gateway_txn_id
    end
    
    if columns(:order_txns).collect {|c| c.name}.include?('credit_card_id')
      remove_column :order_txns, :credit_card_id, :integer
    end
    
    if columns(:order_txns).collect {|c| c.name}.include?('bill_to_first_name')
      remove_column :order_txns, :bill_to_first_name, :string
    end
    
    if columns(:order_txns).collect {|c| c.name}.include?('bill_to_last_name')
      remove_column :order_txns, :bill_to_last_name, :string
    end  
    
    if columns(:order_txns).collect {|c| c.name}.include?('bill_to_address')
      remove_column :order_txns, :bill_to_address, :string
    end
    
    if columns(:order_txns).collect {|c| c.name}.include?('bill_to_city')
      remove_column :order_txns, :bill_to_city, :string
    end   
     
    if columns(:order_txns).collect {|c| c.name}.include?('bill_to_state')
      remove_column :order_txns, :bill_to_state, :string
    end
    
    if columns(:order_txns).collect {|c| c.name}.include?('bill_to_postal_code')
      remove_column :order_txns, :bill_to_postal_code, :string
    end  
    
    if columns(:order_txns).collect {|c| c.name}.include?('bill_to_country')
      remove_column :order_txns, :bill_to_country, :string
    end
    
    if columns(:order_txns).collect {|c| c.name}.include?('bill_to_country_name')
  	  remove_column :order_txns, :bill_to_country, :bill_to_country_name
  	  remove_column :order_txns, :ship_to_country, :ship_to_country_name
    end
    
    #tables
    drop_tables = [
      :credit_cards, 
      :credit_card_accounts,  
      :credit_card_account_party_roles,
      :credit_card_account_purposes
    ]
    drop_tables.each do |table|
      if table_exists?(table)
        drop_table table
      end
    end
    
  end
end
