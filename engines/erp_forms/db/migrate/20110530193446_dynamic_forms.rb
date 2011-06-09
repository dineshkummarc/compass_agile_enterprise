class DynamicForms < ActiveRecord::Migration
  def self.up
    unless table_exists?(:dynamic_form_models)
      create_table :dynamic_form_models do |t|
        t.string :model_name

        t.timestamps
      end
    end

    unless table_exists?(:dynamic_form_documents)
      create_table :dynamic_form_documents do |t|
        t.integer :dynamic_form_model_id
        t.string :type

        t.timestamps
      end

      add_index :dynamic_form_documents, :dynamic_form_model_id
      add_index :dynamic_form_documents, :type
    end

    unless table_exists?(:dynamic_forms)
      create_table :dynamic_forms do |t|
        t.string :description
        t.text :definition        
        t.integer :dynamic_form_model_id
        t.string :model_name
        t.string :internal_identifier
        t.boolean :default

        t.integer :created_by
        t.integer :updated_by

        t.timestamps
      end

      add_index :dynamic_forms, :dynamic_form_model_id
      add_index :dynamic_forms, :model_name
      add_index :dynamic_forms, :internal_identifier
    end

    unless table_exists?(:dynamic_data)
      create_table :dynamic_data do |t|
        t.string :reference_type
        t.integer :reference_id
        t.text :dynamic_attributes        

        t.integer :created_with_form_id
        t.integer :updated_with_form_id

        t.integer :created_by
        t.integer :updated_by

        t.timestamps
      end

      add_index :dynamic_data, :reference_type
      add_index :dynamic_data, :reference_id
    end

  end

  def self.down
    [ :dynamic_form_models, 
      :dynamic_form_documents,
      :dynamic_forms, 
      :dynamic_data
    ].each do |tbl|
      if table_exists?(tbl)
        drop_table tbl
      end
    end
    
  end
end
