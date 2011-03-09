class Knitkit < ActiveRecord::Migration
  def self.up

    unless table_exists?(:sites)
      create_table :sites do |t|
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
        t.string :title
        t.string :type
        t.references :site
        t.string :path
        t.string :permalink
        t.text :layout

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

      #Section.create_versioned_table
    end

    unless table_exists?(:contents)
      create_table :contents do |t|
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

      Content.create_versioned_table
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

    unless table_exists?(:published_sites)
      create_table :published_sites do |t|
        t.references :site
        t.text :comment
        t.decimal :version
        t.boolean :active

        t.timestamps
      end

      #indexes
      add_index :published_sites, :site_id
      add_index :published_sites, :version
      add_index :published_sites, :active
    end

    unless table_exists?(:published_elements)
      create_table :published_elements do |t|
        t.references :published_site
        t.references :published_element_record, :polymorphic => true
        t.integer :version

        t.timestamps
      end

      #indexes
      add_index :published_elements, [:published_element_record_id, :published_element_record_type]
      add_index :published_elements, :published_site_id
      add_index :published_elements, :version
    end

    unless table_exists?(:comments)
      create_table :comments do |t|
        t.string   :commentor_name
        t.string   :email
        t.text     :comment
        t.integer  :approved
        t.datetime :approved_at
        t.references :user
        t.references :commented_record, :polymorphic => true

        t.timestamps
      end

      add_index :comments, [:commented_record_id, :commented_record_type]
      add_index :comments, [:approved]
      add_index :comments, [:user_id]
    end

  end

  def self.down
    #Section.drop_versioned_table
    Content.drop_versioned_table

    # check that each table exists before trying to delete it.
    [:sites, :sections, :contents, :section_contents, :themes, :theme_files, :published_sites, :published_elements, :comments].each do |tbl|
      if table_exists?(tbl)
        drop_table tbl
      end
    end
  end
end
