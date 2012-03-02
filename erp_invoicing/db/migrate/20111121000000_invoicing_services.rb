#***********************************************************************************************************
# TODO
#
# Should all amounts be using amount_ids? Particularly payments, which can be in multiple currencies
# Money amounts in commerce are floats - that doesn't seem right????
#***********************************************************************************************************

class InvoicingServices < ActiveRecord::Migration
  def self.up
    
    # Create invoices
    unless table_exists?(:invoices)
      create_table :invoices do |t|
        t.string     :invoice_number
        t.string     :description
        t.string     :message
        t.date       :invoice_date
        t.date       :due_date
        t.string     :external_identifier
        t.string     :external_id_source
        t.references :product
        t.references :invoice_type
        t.references :billing_account
        t.references :invoice_payment_strategy_type

        t.timestamps
      end

      add_index :invoices, :product_id, :name => 'prod_type_idx'
      add_index :invoices, :invoice_type_id, :name => 'invoice_type_idx'
      add_index :invoices, :billing_account_id, :name => 'invoice_billing_acct_idx'
      add_index :invoices, :invoice_payment_strategy_type_id, :name => 'invoice_payment_stragegy_idx'
    end

    # Create invoice types (not in silverston models - may be removed in future releases)
    unless table_exists?(:invoice_types)

      create_table :invoice_types do |t|
        t.integer :parent_id
        t.integer :lft
        t.integer :rgt

        #custom columns go here
        t.string :description
        t.string :comments
        t.string :internal_identifier
        t.string :external_identifier
        t.string :external_id_source

        t.timestamps
      end
    end

    unless table_exists?(:invoice_payment_strategy_types)
      create_table :invoice_payment_strategy_types do |t|
        t.string   :description
        t.string   :internal_identifier
        t.string   :external_identifier
        t.string   :external_id_source

        t.timestamps
      end
    end
    
    # Create invoice items
    unless table_exists?(:invoice_items)
      create_table :invoice_items do |t|
        #foreign keys      
        t.references :invoice
        t.references :invoice_item_type
        
        #these columns support the polymporphic relationship to invoice-able items
        t.references :invoiceable_item, :polymorphic => true

        #non-key columns
        t.integer    :item_seq_id
        t.string     :item_description
        t.float      :sales_tax
        t.float      :quantity
        t.float      :amount
        
        t.timestamps
      end

      add_index :invoice_items, [:invoiceable_item_id, :invoiceable_item_type], :name => 'invoiceable_item_idx'
      add_index :invoice_items, :invoice_id, :name => 'invoice_id_idx'
      add_index :invoice_items, :invoice_item_type_id, :name => 'invoice_item_type_id_idx'
    end
    
    # Create invoice item types
    unless table_exists?(:invoice_item_types)
      create_table :invoice_item_types do |t|
        t.integer :parent_id
        t.integer :lft
        t.integer :rgt

        #custom columns go here
        t.string :description
        t.string :comments
        t.string :internal_identifier
        t.string :external_identifier
        t.string :external_id_source

        t.timestamps
      end
    end
    
    # Create invoice_party_roles
    unless table_exists?(:invoice_party_roles)
      create_table :invoice_party_roles do |t|
        t.string :description
        t.integer :role_type_id
        t.string :external_identifier
        t.string :external_id_source
        t.references :invoice
        t.references :party
        
        t.timestamps
      end

      add_index :invoice_party_roles, :invoice_id, :name => 'invoice_party_invoice_id_idx'
      add_index :invoice_party_roles, :party_id, :name => 'invoice_party_party_id_idx'
    end


    unless table_exists?(:billing_accounts)
      create_table :billing_accounts do |t|
        t.boolean :send_paper_bills, :default => false
        t.boolean :payable_online, :default => false
        t.date    :billing_date

        t.timestamps
      end
    end

    # Create billing contact mechanisms
    unless table_exists?(:billing_contact_mechanisms)
      create_table :billing_contact_mechanisms do |t|
        t.string :description
        #these columns support a polymorphic relationship to the contact mechanism for an invoice and billing account
        #this allows for the use of email, postal addresses and other contact points to be used in billing
        t.references :contact_mechanism, :polymorphic => true
    
        t.timestamps
      end

      add_index :billing_contact_mechanisms, [:contact_mechanism_id, :contact_mechanism_type], :name => 'billing_contact_mechanism_idx'
    end

    unless table_exists?(:recurring_payments)
      create_table :recurring_payments do |t|
        t.references :payment_account, :polymorphic => true
        t.references :billing_account
        t.float    :pay_up_to_amount
        t.float    :payment_amount
        t.integer  :payment_day
        t.date     :from_date
        t.date     :thru_date
        t.boolean  :enabled

        t.timestamps
      end

      add_index :recurring_payments, [:payment_account_id, :payment_account_type], :name => 'payment_account_idx'
      add_index :recurring_payments, :billing_account_id
    end

    # Create payment applictions
    unless table_exists?(:payment_applications)
      create_table :payment_applications do |t|
        
        t.integer :financial_txn_id

        #these columns support the polymporphic relationship to the entities to which payments can be applied
        #this will be innvoices, invoice items or accounts
        t.references :payment_applied_to, :polymorphic => true
        
        #Payments here is set up to point to an amount which allows it to be
        #in multiple currencies
        t.integer :applied_money_amount_id
        t.string :comment
                        
        t.timestamps
      end

      add_index :payment_applications, [:payment_applied_to_id, :payment_applied_to_type], :name => 'payment_applied_to_idx'
      add_index :payment_applications, :financial_txn_id
      add_index :payment_applications, :applied_money_amount_id
    end

    unless table_exists? :invoice_payment_term_sets
      create_table :invoice_payment_term_sets do |t|
        #foreign keys
        t.references :invoice
        t.references :invoice_item

        #custom columns go here
        t.string :description
        t.string :comments
        t.string :internal_identifier
        t.string :external_identifier
        t.string :external_id_source

        t.timestamps
      end

      add_index :invoice_payment_term_sets, :invoice_id
      add_index :invoice_payment_term_sets, :invoice_item_id
    end

    unless table_exists? :invoice_payment_terms
      create_table :invoice_payment_terms do |t|
        #foreign keys
        t.references :invoice_payment_term_type
        t.references :invoice_payment_term_set

        #non-key columns
        t.string :description
        t.date :pay_by
        t.float :amount

        t.timestamps
      end

      add_index :invoice_payment_terms, :invoice_payment_term_type_id
      add_index :invoice_payment_terms, :invoice_payment_term_set_id
    end

    unless table_exists? :invoice_payment_term_types
      create_table :invoice_payment_term_types do |t|
        #awesome nested set columns
        t.integer :parent_id
        t.integer :lft
        t.integer :rgt

        #custom columns go here
        t.string :description
        t.string :comments
        t.string :internal_identifier
        t.string :external_identifier
        t.string :external_id_source

        t.timestamps
      end
    end

    
  end

  def self.down
    [
      :invoices, :invoice_types, :invoice_payment_strategy_types,
      :invoice_items, :invoice_item_types, :invoice_party_roles,
      :billing_accounts, :billing_contact_mechanisms,
      :payment_applications, :payment_party_roles, :recurring_payments,
      :invoice_payment_term_sets,:invoice_payment_terms,:invoice_payment_term_types
    ].each do |tbl|
      if table_exists?(tbl)
        drop_table tbl
      end
    end

  end
end