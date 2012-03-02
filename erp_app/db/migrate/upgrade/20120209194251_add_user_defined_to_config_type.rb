class AddUserDefinedToConfigType < ActiveRecord::Migration
  def change
    add_column :configuration_item_types, :allow_user_defined_options, :boolean, :default => false unless column_exists? :configuration_item_types, :allow_user_defined_options
  end
end
