class Knitkit < ActiveRecord::Migration
  def self.up
    
    unless table_exists?(:sites)
      create_table :sites do |t|
        t.integer :id
        t.string :name
        t.string :host
        t.string :title
        t.string :subtitle
        t.string :email

        t.timestamps
      end
    end
    
    unless table_exists?(:sections)
      create_table :sections do |t|
        t.integer :id
        t.string :title
        t.string :type
        t.references :site
        t.string :path
        t.string :permalink
        t.string :template
        
        #better nested set columns
        t.integer :parent_id
        t.integer :lft
        t.integer :rgt
        
        t.timestamps
      end
      #indexes
      add_index :sections, :site_id
      add_index :sections, :parent_id
      add_index :sections, :lft
      add_index :sections, :rgt
    end
    
    unless table_exists?(:contents)
      create_table :contents do |t|
        t.integer :id
        t.string :type
        t.string :title
        t.string :permalink
        t.string :content_area
        t.text :excerpt_html
        t.text :body_html

        t.timestamps
      end
      #indexes
      add_index :contents, :type
    end
    
    unless table_exists?(:section_contents)
      create_table :section_contents do |t|
        t.integer :section_id
        t.integer :content_id
        t.integer :position

        t.timestamps
      end
      #indexes
      add_index :section_contents, :section_id
      add_index :section_contents, :content_id
      add_index :section_contents, :position
    end
     
    unless table_exists?(:themes)
      create_table :themes do |t|
        t.references :site
        t.string :name
        t.string :theme_id
        t.string :author
        t.integer :version
        t.string :homepage
        t.text :summary
        t.integer :active

        t.timestamps
      end
      #indexes
      add_index :themes, :site_id
      add_index :themes, :active
    end
    
    unless table_exists?(:theme_files)
      create_table :theme_files do |t|
        t.references :theme
        t.string :type
        t.string :name
        t.string :directory
        t.string :data_file_name
        t.string :data_content_type
        t.integer :data_file_size
        t.datetime :data_updated_at

        t.timestamps
      end
    end
    
  end

  def self.down
    # check that each table exists before trying to delete it.
    [:sites, :sections, :contents, :section_contents, :themes, :theme_files].each do |tbl|
      if table_exists?(tbl)
        drop_table tbl
      end
    end
  end
end
