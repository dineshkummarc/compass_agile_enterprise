class SetupPayments < ActiveRecord::Migration
  def self.up
    
    unless table_exists?(:payments)
      create_table :payments do |t|

        t.column :success,             :boolean
        t.column :reference_number,    :string
        t.column :financial_txn_id,    :integer
        t.column :current_state,       :string
        t.column :authorization_code,  :string
              
        t.timestamps
      end
        
      add_index :payments, :financial_txn_id
    end

    unless table_exists?(:payment_gateways)
      create_table :payment_gateways do |t|

        t.column :params,                      :string
        t.column :payment_gateway_action_id,   :integer
        t.column :payment_id,   :integer
        t.column :response,                    :string

        t.timestamps
      end
    end

    unless table_exists?(:payment_gateway_actions)
      create_table :payment_gateway_actions do |t|

        t.column :internal_identifier, :string
        t.column :description,         :string

        t.timestamps
      end
    end

    add_index :payment_gateway_actions, :internal_identifier
  end

  def self.down
    drop_tables = [
      :payments,
      :payment_gateways,
      :payment_gateway_actions
    ]
    drop_tables.each do |table|
      if table_exists?(table)
        drop_table table
      end
    end
    
  end
end
