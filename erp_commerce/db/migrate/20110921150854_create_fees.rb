class CreateFees < ActiveRecord::Migration
  def up
    unless table_exists?(:fees)
        create_table :fees do |t|
          t.references :fee_record, :polymorphic => true     
          t.references :money
          t.references :fee_type
          t.string     :description
          t.datetime   :start_date
          t.datetime   :end_date
          t.string     :external_identifier
          t.string     :external_id_source

          t.timestamps
        end

        add_index :fees, [:fee_record_id, :fee_record_type], :name => 'fee_record_idx'
        add_index :fees, :fee_type_id
        add_index :fees, :money_id
    end
    
    unless table_exists?(:fee_types)
        create_table :fee_types do |t|
          t.string :internal_identifier    
          t.string :description
          t.string :comments
          t.string :external_identifier
          t.string :external_id_source
          
          #these columns are required to support the behavior of the plugin 'awesome_nested_set'
          t.integer  	:parent_id
          t.integer  	:lft
          t.integer  	:rgt
          
          t.timestamps
        end

    end
  end

  def down
    #tables
    drop_tables = [:fees,:fee_types]
    drop_tables.each do |table|
      if table_exists?(table)
        drop_table table
      end
    end
  end
end
