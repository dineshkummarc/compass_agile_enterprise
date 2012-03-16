class AddIsTemplateToConfigurations < ActiveRecord::Migration
  def change
    add_column :configurations, :is_template, :boolean, :default => false
  end
end
