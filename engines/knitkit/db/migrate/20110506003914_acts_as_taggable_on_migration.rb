class ActsAsTaggableOnMigration < ActiveRecord::Migration
  def self.up
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
      add_index :taggings, [:taggable_id, :taggable_type, :context]
    end
  end
  
  def self.down
    drop_table :taggings if table_exists?(:taggings)
    drop_table :tags  if table_exists?(:tags)
  end
end
