class UpdateConfigurationJoinTables < ActiveRecord::Migration
  def up
    if column_exists? :configuration_item_types_configurations, :created_at
      remove_column :configuration_item_types_configurations, :created_at
      remove_column :configuration_item_types_configurations, :updated_at

      remove_column :configuration_items_configuration_options, :created_at
      remove_column :configuration_items_configuration_options, :updated_at
      
      add_index :configuration_item_types_configurations, [:configuration_item_type_id, :configuration_id], :unique => true, :name => 'conf_config_type_uniq_idx'
    end
  end

  def down
  end
end
