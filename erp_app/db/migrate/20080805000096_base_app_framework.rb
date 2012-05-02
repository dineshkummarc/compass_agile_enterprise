class BaseAppFramework < ActiveRecord::Migration
  def self.up

    unless table_exists?(:preferences)
      create_table :preferences do |t|
        t.references :preference_option
        t.references :preference_type

        t.timestamps
      end
      add_index :preferences, :preference_option_id
      add_index :preferences, :preference_type_id
    end

    unless table_exists?(:preference_types)
      create_table :preference_types do |t|
        t.string :description
        t.string :internal_identifier
        t.integer :default_pref_option_id

        t.timestamps
      end

      add_index :preference_types, :default_pref_option_id
    end

    unless table_exists?(:preference_options)
      create_table :preference_options do |t|
        t.string :description
        t.string :internal_identifier
        t.string :value

        t.timestamps
      end
    end

    unless table_exists?(:preference_options_preference_types)
      create_table :preference_options_preference_types, {:id => false} do |t|
        t.references :preference_type
        t.references :preference_option

        t.timestamps
      end

      add_index :preference_options_preference_types, :preference_type_id, :name => 'pref_opt_pref_type_pref_type_id_idx'
      add_index :preference_options_preference_types, :preference_option_id, :name => 'pref_opt_pref_type_pref_opt_id_idx'
    end

    unless table_exists?(:valid_preference_types)
      create_table :valid_preference_types do |t|
        t.references :preference_type
        t.references :preferenced_record, :polymorphic => true
      end
    end

    unless table_exists?(:user_preferences)
      create_table :user_preferences do |t|
        t.references :user
        t.references :preference

        t.references :preferenced_record, :polymorphic => true

        t.timestamps
      end
      add_index :user_preferences, :user_id
      add_index :user_preferences, :preference_id
      add_index :user_preferences, :preferenced_record_id
      add_index :user_preferences, :preferenced_record_type
    end

    unless table_exists?(:app_containers)
      create_table :app_containers do |t|
        t.references :user
        t.string :description
        t.string :internal_identifier
        t.string :type

        t.timestamps
      end
      add_index :app_containers, :user_id
      add_index :app_containers, :type
    end

    unless table_exists?(:applications)
      create_table :applications do |t|
        t.column :description,           :string
        t.column :icon,                  :string
        t.column :internal_identifier,   :string
        t.column :javascript_class_name, :string
        t.column :shortcut_id,           :string
        t.column :base_url,              :string
        t.column :type,                  :string

        t.timestamps
      end
    end

    unless table_exists?(:app_containers_applications)
      create_table :app_containers_applications, {:id => false} do |t|
        t.column :app_container_id, :integer
        t.column :application_id,   :integer

        t.timestamps
      end

      add_index :app_containers_applications, :application_id
      add_index :app_containers_applications, :app_container_id
    end

    unless table_exists?(:widgets)
      create_table :widgets do |t|
        t.column :description,           :string
        t.column :internal_identifier,   :string
        t.column :icon,                  :string
        t.column :xtype,                 :string

        t.timestamps
      end
    end

    unless table_exists?(:applications_widgets)
      create_table :applications_widgets, {:id => false} do |t|
        t.column :application_id, :integer
        t.column :widget_id,      :integer

        t.timestamps
      end
      add_index :applications_widgets, :application_id
      add_index :applications_widgets, :widget_id
    end

    unless table_exists?(:tree_menu_node_defs)
      create_table :tree_menu_node_defs do |t|
        t.string  :node_type
        t.integer :parent_id
        t.integer :lft
        t.integer :rgt
        t.string 	:menu_short_name
        t.string 	:menu_description
        t.string  :text
        t.string  :icon_url
        t.string  :target_url
        t.string  :resource_class
        t.timestamps
      end
      add_index :tree_menu_node_defs, :parent_id
    end

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
        t.boolean    :allow_user_defined_options, :default => false
        t.boolean    :is_multi_optional, :default => false

        t.timestamps
      end
    end

    unless table_exists?(:configuration_item_types_configurations)
      create_table :configuration_item_types_configurations, {:id => false} do |t|
        t.references :configuration_item_type
        t.references :configuration
      end

      add_index :configuration_item_types_configurations, :configuration_item_type_id, :name => 'conf_conf_type_id_item_idx'
      add_index :configuration_item_types_configurations, :configuration_id, :name => 'conf_id_idx'
      add_index :configuration_item_types_configurations, [:configuration_item_type_id, :configuration_id], :unique => true, :name => 'conf_config_type_uniq_idx'
    end

    unless table_exists? :configuration_options
      create_table :configuration_options do |t|
        #custom columns go here
        t.string  :description
        t.string  :internal_identifier
        t.string  :value
        t.text    :comment
        t.boolean :user_defined, :default => false

        t.timestamps
      end

      add_index :configuration_options, :value
      add_index :configuration_options, :internal_identifier
      add_index :configuration_options, :user_defined
    end

    unless table_exists?(:configuration_item_types_configuration_options)
      create_table :configuration_item_types_configuration_options do |t|
        t.references :configuration_item_type
        t.references :configuration_option
        t.boolean :is_default, :default => false

        t.timestamps
      end

      add_index :configuration_item_types_configuration_options, :configuration_item_type_id, :name => 'conf_item_type_conf_opt_id_item_idx'
      add_index :configuration_item_types_configuration_options, :configuration_option_id, :name => 'conf_item_type_conf_opt_id_opt_idx'
    end

    unless table_exists?(:configuration_items_configuration_options)
      create_table :configuration_items_configuration_options, {:id => false} do |t|
        t.references :configuration_item
        t.references :configuration_option
      end

      add_index :configuration_items_configuration_options, :configuration_item_id, :name => 'conf_item_conf_opt_id_item_idx'
      add_index :configuration_items_configuration_options, :configuration_option_id, :name => 'conf_item_conf_opt_id_opt_idx'
    end

  end

  def self.down
    [
      :preferences,:preference_types,
      :preference_options,:preference_options_preference_types,
      :valid_preference_types,:user_preferences,
      :app_containers,:app_containers_applications,
      :applications_widgets,
      :applications,:applications_desktops,
      :desktops,:widgets,:tree_menu_node_defs,
      :configurations,:configuration_items,
      :configuration_item_types,:configuration_options,
      :configuration_item_types_configuration_options,
      :configuration_items_configuration_options,:configured_items,
      :configuration_item_types_configurations
    ].each do |tbl|
      if table_exists?(tbl)
        drop_table(tbl)
      end
    end
  end

end
