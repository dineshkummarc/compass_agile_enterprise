class AddConfigurationModels < ActiveRecord::Migration
  def up
    unless table_exists? :configurations
      create_table :configurations do |t|
        #custom columns go here
        t.string  :description
        t.string  :internal_identifier
        t.boolean :active

        t.timestamps
      end
    end

    unless table_exists? :valid_configurations
      create_table :valid_configurations do |t|
        #foreign keys
        t.references :configured_item, :polymorphic => true
        t.references :configuration

        t.timestamps
      end

      add_index :valid_configurations, [:configured_item_id, :configured_item_type], :name => 'configured_item_poly_idx'
      add_index :valid_configurations, :configuration_id
    end

    unless table_exists? :configuration_items
      create_table :configuration_items do |t|
        #foreign keys
        t.references :configuration
        t.references :configuration_item_type
        t.references :configuration_option

        t.timestamps
      end

      add_index :configuration_items, :configuration_id
      add_index :configuration_items, :configuration_item_type_id
      add_index :configuration_items, :configuration_option_id
    end

    unless table_exists? :configuration_item_types
      create_table :configuration_item_types do |t|
        #awesome nested set columns
        t.integer :parent_id
        t.integer :lft
        t.integer :rgt

        #custom columns go here
        t.string     :description
        t.string     :internal_identifier
        t.boolean    :is_multi_optional, :default => false
        t.references :default_configuration_option

        t.timestamps
      end

      add_index :configuration_item_types, :default_configuration_option_id, :name => 'configuration_item_dflt_opt_idx'
    end

    unless table_exists? :configuration_options
      create_table :configuration_options do |t|
        #custom columns go here
        t.string :description
        t.string :internal_identifier
        t.string :value
        t.text   :comment

        t.timestamps
      end
    end

    unless table_exists?(:configuration_item_types_configuration_options)
      create_table :configuration_item_types_configuration_options, {:id => false} do |t|
        t.references :configuration_item_type
        t.references :configuration_option

        t.timestamps
      end

      add_index :configuration_item_types_configuration_options, :configuration_item_type_id, :name => 'conf_type_conf_opt_id_item_idx'
      add_index :configuration_item_types_configuration_options, :configuration_option_id, :name => 'conf_type_conf_opt_id_opt_idx'
    end

    unless table_exists?(:configuration_items_configuration_options)
      create_table :configuration_items_configuration_options, {:id => false} do |t|
        t.references :configuration_item
        t.references :configuration_option

        t.timestamps
      end

      add_index :configuration_items_configuration_options, :configuration_item_id, :name => 'conf_item_conf_opt_id_item_idx'
      add_index :configuration_items_configuration_options, :configuration_option_id, :name => 'conf_item_conf_opt_id_opt_idx'
    end
  end

  def down
     [:configurations,:configuration_items,
      :configuration_item_types,:configuration_options,
      :configuration_item_types_configuration_options,
      :configuration_items_configuration_options,:configured_items
    ].each do |tbl|
      if table_exists?(tbl)
        drop_table(tbl)
      end
    end
  end
end
