class AddUserDefinedToConfigOption < ActiveRecord::Migration
  
  def up
    unless column_exists? :configuration_options, :user_defined
      add_column :configuration_options, :user_defined, :boolean, :default => false

      add_index :configuration_options, :value
      add_index :configuration_options, :internal_identifier
      add_index :configuration_options, :user_defined
    end
  end
  
  def down
    #remove data here
  end

end
