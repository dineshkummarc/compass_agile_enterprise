class AddConfigTypesToConfigs < ActiveRecord::Migration
  def change
    unless table_exists?(:configuration_item_types_configurations)
      create_table :configuration_item_types_configurations, {:id => false} do |t|
        t.references :configuration_item_type
        t.references :configuration

        t.timestamps
      end

      add_index :configuration_item_types_configurations, :configuration_item_type_id, :name => 'conf_item_type_conf_opt_id_item_idx'
      add_index :configuration_item_types_configurations, :configuration_id, :name => 'conf_id_idx'
    end

    unless column_exists? :configuration_item_types_configuration_options, :id
      add_column :configuration_item_types_configuration_options, :id, :integer
      add_column :configuration_item_types_configuration_options, :is_default, :boolean, :default => false

      #remove_index :configuration_item_types, 'configuration_item_dflt_opt_idx'
      remove_column :configuration_item_types, :default_configuration_option_id
    end
  end
end
