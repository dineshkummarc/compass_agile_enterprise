class CreateHasAttributeTables < ActiveRecord::Migration
  def up
    unless table_exists?(:attribute_types)
      create_table :attribute_types do |t|
        t.string :internal_identifier
        t.string :description
        t.string :data_type

        t.timestamps
      end

      add_index :attribute_types, :internal_identifier,  :name => ':attribute_types_iid_idx'
    end
    unless table_exists?(:attribute_values)
      create_table :attribute_values do |t|
        t.integer :attributed_record_id
        t.string :attributed_record_type
        t.references :attribute_type
        t.string  :value

        t.timestamps
      end

      add_index :attribute_values, [:attributed_record_id, :attributed_record_type], :name => 'attribute_values_attributed_record_idx'
      add_index :attribute_values, :attribute_type_id,  :name => 'attribute_values_attributed_type_idx'
      add_index :attribute_values, :value,  :name => 'attribute_values_value_idx'
    end
  end

  def down
    if table_exists?(:attribute_types)
      drop_table :attribute_types
    end
    if table_exists?(:attribute_values)
      drop_table :attribute_values
    end
  end
end
