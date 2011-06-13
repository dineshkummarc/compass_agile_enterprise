class AddDefaultsToPositionColumns < ActiveRecord::Migration
  def self.up
    change_column_default(:website_sections, :position, 0)
    change_column_default(:website_section_contents, :position, 0)
    change_column_default(:website_nav_items, :position, 0)
  end

  def self.down
    #no down there were no defaults
  end
end
