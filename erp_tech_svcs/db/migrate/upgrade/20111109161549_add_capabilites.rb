class AddCapabilites < ActiveRecord::Migration
  def up
    unless table_exists?(:capable_models)
      # create the roles table
      create_table :capable_models do |t|
        t.references :capable_model_record, :polymorphic => true

        t.timestamps
      end

      add_index :capable_models, [:capable_model_record_id, :capable_model_record_type], :name => 'capable_model_record_idx'
    end

    unless table_exists?(:capability_types)
      # create the roles table
      create_table :capability_types do |t|
        t.string :internal_identifier
        t.string :description
        t.timestamps
      end
    end

    unless table_exists?(:capabilities)
      # create the roles table
      create_table :capabilities do |t|
        t.string :resource
        t.references :capability_type
        t.timestamps
      end

      add_index :capabilities, :capability_type_id
    end

    unless table_exists?(:capabilities_capable_models)
      # create the roles table
      create_table :capabilities_capable_models, :id => false do |t|
        t.references :capable_model
        t.references :capability
        t.timestamps
      end

      add_index :capabilities_capable_models, :capable_model_id
      add_index :capabilities_capable_models, :capability_id
    end
  end

  def down
    [
      :capable_models, :capability_types, :capabilities,:capabilities_capable_models
    ].each do |tbl|
      if table_exists?(tbl)
        drop_table tbl
      end
    end
  end
end
