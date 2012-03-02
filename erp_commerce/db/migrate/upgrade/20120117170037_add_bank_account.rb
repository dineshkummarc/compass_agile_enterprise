class AddBankAccount < ActiveRecord::Migration
  def up
    unless table_exists?(:bank_account_types)
      create_table :bank_account_types do |t|
        t.string :description
        t.string :internal_identifier

        t.timestamps
      end
    end

    unless table_exists?(:bank_accounts)
      create_table :bank_accounts do |t|
        t.string :routing_number
        t.string :crypted_private_account_number
        t.string :name_on_account
        t.references :bank_account_type

        t.timestamps
      end

      add_index :bank_accounts, :bank_account_type_id, :name => 'bank_accounts_account_type_idx'
    end

  end

  def down
    [:bank_account_types, :bank_accounts].each do |tbl|
      if table_exists?(tbl)
        drop_table tbl
      end
    end
  end
end
