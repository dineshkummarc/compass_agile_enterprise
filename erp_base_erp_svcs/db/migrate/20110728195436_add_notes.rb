class AddNotes < ActiveRecord::Migration
  def self.up
    unless table_exists?(:notes)
      create_table   :notes do |t|
        t.integer    :created_by_id
        t.text       :content
        t.references :noted_record, :polymorphic => true
        t.references :note_type

        t.timestamps
      end

      add_index :notes, [:noted_record_id, :noted_record_type]
      add_index :notes, :note_type_id
      add_index :notes, :created_by_id
      add_index :notes, :content
    end

    unless table_exists?(:note_types)
      create_table :note_types do |t|
        #these columns are required to support the behavior of the plugin 'awesome_nested_set'
        t.integer  	:parent_id
        t.integer  	:lft
        t.integer  	:rgt

        t.string     :description
        t.string     :internal_identifier
        t.string     :external_identifier
        t.references :note_type_record, :polymorphic => true

        t.timestamps
      end

      add_index :note_types, [:note_type_record_id, :note_type_record_type]
    end
  end

  def self.down
    [:notes, :note_types].each do |tbl|
      if table_exists?(tbl)
        drop_table tbl
      end
    end
  end
end
