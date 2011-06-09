class SetupKnitkit < ActiveRecord::Migration
  def self.up

    unless table_exists?(:websites)
      create_table :websites do |t|
        t.string :name
        t.string :title
        t.string :subtitle
        t.string :email
        t.boolean :auto_activate_publication
        t.boolean :email_inquiries

        t.timestamps
      end
    end

    unless table_exists?(:website_hosts)
      create_table :website_hosts do |t|
        t.references :website
        t.string :host

        t.timestamps
      end

      add_index :website_hosts, :website_id
    end

    unless table_exists?(:website_sections)
      create_table :website_sections do |t|
        t.string :title
        t.string :type
        t.references :website
        t.string :path
        t.string :permalink
        t.text :layout
        t.boolean :in_menu
        t.integer :position, :default => 0

        #better nested set columns
        t.integer :parent_id
        t.integer :lft
        t.integer :rgt

        t.timestamps
      end
      #indexes
      add_index :website_sections, :website_id
      add_index :website_sections, :position
      add_index :website_sections, :parent_id
      add_index :website_sections, :lft
      add_index :website_sections, :rgt

      WebsiteSection.create_versioned_table
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

    unless table_exists?(:website_section_contents)
      create_table :website_section_contents do |t|
        t.integer :website_section_id
        t.integer :content_id
        t.integer :position, :default => 0

        t.timestamps
      end
      #indexes
      add_index :website_section_contents, :website_section_id
      add_index :website_section_contents, :content_id
      add_index :website_section_contents, :position
    end

    unless table_exists?(:themes)
      create_table :themes do |t|
        t.references :website
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
      add_index :themes, :website_id
      add_index :themes, :active
    end

    unless table_exists?(:published_websites)
      create_table :published_websites do |t|
        t.references :website
        t.text :comment
        t.decimal :version
        t.boolean :active

        t.timestamps
      end

      #indexes
      add_index :published_websites, :website_id
      add_index :published_websites, :version
      add_index :published_websites, :active
    end

    unless table_exists?(:published_elements)
      create_table :published_elements do |t|
        t.references :published_website
        t.references :published_element_record, :polymorphic => true
        t.integer :version

        t.timestamps
      end

      #indexes
      add_index :published_elements, [:published_element_record_id, :published_element_record_type], :name => 'published_elm_idx'
      add_index :published_elements, :published_website_id
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

      add_index :comments, [:commented_record_id, :commented_record_type], :name => 'commented_record_idx'
      add_index :comments, [:approved]
      add_index :comments, [:user_id]
    end

    unless table_exists?(:website_nav_items)
      create_table :website_nav_items do |t|
        t.references :website_nav
        t.string :title
        t.string :url
        t.integer :position, :default => 0

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
    WebsiteSection.drop_versioned_table
    Content.drop_versioned_table

    # check that each table exists before trying to delete it.
    [:websites, :website_sections, :contents, :website_section_contents,
      :themes, :theme_files, :published_websites, :published_elements,
      :comments,:website_hosts,:website_nav_items, :website_navs].each do |tbl|
      if table_exists?(tbl)
        drop_table tbl
      end
    end
  end
end
