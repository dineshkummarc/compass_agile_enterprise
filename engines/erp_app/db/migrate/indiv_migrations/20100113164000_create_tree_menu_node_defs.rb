class CreateTreeMenuNodeDefs < ActiveRecord::Migration
  def self.up
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
  end

  def self.down
    drop_table :tree_menu_node_defs
  end
end
