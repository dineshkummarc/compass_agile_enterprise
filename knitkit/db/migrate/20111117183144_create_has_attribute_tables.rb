class CreateHasAttributeTables < ActiveRecord::Migration
  def up
    unless table_exists?(:attribute_types)
      create_table :attribute_types do |t|
        t.string :internal_identifier
        t.string :description
        t.string :data_type

        t.timestamps
      end
    end
    unless table_exists?(:attribute_values)
      create_table :attribute_values do |t|
        t.integer :attributed_record_id
        t.string :attributed_record_type
        t.references :attribute_type
        t.string  :value

        t.timestamps
      end
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
