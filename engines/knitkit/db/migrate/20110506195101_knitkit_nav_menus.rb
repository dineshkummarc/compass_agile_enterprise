class KnitkitNavMenus < ActiveRecord::Migration
  def self.up

    unless columns(:website_sections).collect {|c| c.name}.include?('position')
      add_column :website_sections, :position, :integer
      add_index :website_sections, :position
    end

    unless table_exists?(:website_nav_items)
      create_table :website_nav_items do |t|
        t.references :website_nav
        t.string :title
        t.string :url
        t.integer :position

        #better nested set columns
        t.integer :parent_id
        t.integer :lft
        t.integer :rgt

        t.timestamps
      end

      add_index :website_nav_items, :website_nav_id
      add_index :website_nav_items, :position
      add_index :website_nav_items, :parent_id
      add_index :website_nav_items, :lft
      add_index :website_nav_items, :rgt
    end

    unless table_exists?(:website_navs)
      create_table :website_navs do |t|
        t.references :website
        t.string :name

        t.timestamps
      end

      add_index :website_navs, :website_id
    end
  end

  def self.down
   remove_column :website_sections, :position

   drop_table :website_nav_items if table_exists?(:website_nav_items)
   drop_table :website_navs if table_exists?(:website_navs)
  end
end
