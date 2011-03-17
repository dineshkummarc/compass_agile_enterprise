class SetupKnitkit < ActiveRecord::Migration
  def self.up

    unless table_exists?(:websites)
      create_table :websites do |t|
        t.string :name
        t.string :host
        t.string :title
        t.string :subtitle
        t.string :email
        t.boolean :allow_inquiries
        t.boolean :email_inquiries

        t.timestamps
      end
    end

    unless table_exists?(:website_sections)
      create_table :website_sections do |t|
        t.string :title
        t.string :type
        t.references :website
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
      add_index :website_sections, :website_id
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
        t.integer :position

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
      add_index :published_elements, [:published_element_record_id, :published_element_record_type]
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

      add_index :comments, [:commented_record_id, :commented_record_type]
      add_index :comments, [:approved]
      add_index :comments, [:user_id]
    end

    unless table_exists?(:website_inquiries)
      create_table :website_inquiries do |t|
        t.string   :first_name
        t.string   :last_name
        t.string   :email
        t.text     :inquiry
        t.references :user
        t.references :website

        t.timestamps
      end

      add_index :website_inquiries, [:user_id]
      add_index :website_inquiries, [:website_id]
    end

  end

  def self.down
    WebsiteSection.drop_versioned_table
    Content.drop_versioned_table

    # check that each table exists before trying to delete it.
    [:websites, :website_sections, :contents, :website_section_contents, :themes, :theme_files, :published_websites, :published_elements, :comments, :website_inquiries].each do |tbl|
      if table_exists?(tbl)
        drop_table tbl
      end
    end
  end
end
