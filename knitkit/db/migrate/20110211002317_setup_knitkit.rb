class SetupKnitkit < ActiveRecord::Migration
  def self.up

    unless table_exists?(:websites)
      create_table :websites do |t|
        t.string :name
        t.string :title
        t.string :subtitle
        t.string :internal_identifier
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

    unless table_exists?(:website_inquiries)
      create_table :website_inquiries do |t|
        t.integer :website_id

        t.timestamps
      end

      add_index :website_inquiries, :website_id
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
        t.string :internal_identifier
        t.integer :version
        t.boolean :render_base_layout, :default => true

        #better nested set columns
        t.integer :parent_id
        t.integer :lft
        t.integer :rgt

        t.timestamps
      end
      #indexes
      add_index :website_sections, :permalink
      add_index :website_sections, :website_id
      add_index :website_sections, :position
      add_index :website_sections, :parent_id
      add_index :website_sections, :lft
      add_index :website_sections, :rgt
      add_index :website_sections, :version
      add_index :website_sections, :internal_identifier, :name => 'section_iid_idx'

      WebsiteSection.create_versioned_table
    end

    unless table_exists?(:contents)
      create_table :contents do |t|
        t.string :type
        t.string :title
        t.string :permalink
        t.text :excerpt_html
        t.text :body_html
        t.integer :created_by_id
        t.integer :updated_by_id
        t.string :internal_identifier
        t.boolean :display_title
        t.integer :version

        t.timestamps
      end
      #indexes
      add_index :contents, :type
      add_index :contents, :created_by_id
      add_index :contents, :updated_by_id
      add_index :contents, :permalink
      add_index :contents, :version
      add_index :contents, :internal_identifier, :name => 'contents_iid_idx'

      Content.create_versioned_table
    end

    unless table_exists?(:website_section_contents)
      create_table :website_section_contents do |t|
        t.integer :website_section_id
        t.integer :content_id
        t.string  :content_area
        t.integer :position, :default => 0

        t.timestamps
      end
      #indexes
      add_index :website_section_contents, :website_section_id
      add_index :website_section_contents, :content_id
      add_index :website_section_contents, :position
      add_index :website_section_contents, :content_area
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
        t.decimal :version, :precision => 18, :scale => 6
        t.boolean :active
        t.integer :published_by_id

        t.timestamps
      end

      #indexes
      add_index :published_websites, :website_id
      add_index :published_websites, :version
      add_index :published_websites, :active
      add_index :published_websites, :published_by_id
    end

    unless table_exists?(:published_elements)
      create_table :published_elements do |t|
        t.references :published_website
        t.references :published_element_record, :polymorphic => true
        t.integer :version
        t.integer :published_by_id

        t.timestamps
      end

      #indexes
      add_index :published_elements, [:published_element_record_id, :published_element_record_type], :name => 'published_elm_idx'
      add_index :published_elements, :published_website_id
      add_index :published_elements, :version
      add_index :published_elements, :published_by_id
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
        t.references :linked_to_item, :polymorphic => true

        #better nested set columns
        t.integer :parent_id
        t.integer :lft
        t.integer :rgt

        t.timestamps
      end

      add_index :website_nav_items, [:linked_to_item_id, :linked_to_item_type], :name => 'linked_to_idx'
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

    unless table_exists?(:tags)
      create_table :tags do |t|
        t.column :name, :string
      end
    end

    unless table_exists?(:taggings)
      create_table :taggings do |t|
        t.column :tag_id, :integer
        t.column :taggable_id, :integer
        t.column :tagger_id, :integer
        t.column :tagger_type, :string

        # You should make sure that the column created is
        # long enough to store the required class names.
        t.column :taggable_type, :string
        t.column :context, :string

        t.column :created_at, :datetime
      end

      add_index :taggings, :tag_id
      add_index :taggings, [:taggable_id, :taggable_type, :context], :name => 'taggable_poly_idx'
    end

    unless table_exists? :website_party_roles
      create_table :website_party_roles do |t|
        #foreign keys
        t.references :website
        t.references :role_type
        t.references :party

        t.timestamps
      end

      add_index :website_party_roles, :website_id
      add_index :website_party_roles, :role_type_id
      add_index :website_party_roles, :party_id
    end

  end

  def self.down
    WebsiteSection.drop_versioned_table
    Content.drop_versioned_table

    # check that each table exists before trying to delete it.
    [:websites, :website_sections, :contents, :website_section_contents,
      :themes, :theme_files, :published_websites, :published_elements, :website_party_roles,
      :comments,:website_hosts,:website_nav_items, :website_navs, :tags, :taggings].each do |tbl|
      if table_exists?(tbl)
        drop_table tbl
      end
    end
  end
end
