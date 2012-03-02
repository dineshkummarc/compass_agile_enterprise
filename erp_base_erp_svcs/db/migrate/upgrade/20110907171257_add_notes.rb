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

      add_index :note_types, [:note_type_record_id, :note_type_record_type], :name => "note_type_record_idx"
    end

    unless table_exists?(:valid_note_types)
      create_table   :valid_note_types do |t|
        t.references :valid_note_type_record, :polymorphic => true
        t.references :note_type

        t.timestamps
      end

      add_index :valid_note_types, [:valid_note_type_record_id, :valid_note_type_record_type], :name => "valid_note_type_record_idx"
      add_index :valid_note_types, :note_type_id
    end
  end

  def self.down
    if table_exists?(:valid_note_types)
      drop_table :valid_note_types
    end

    if table_exists?(:note_types)
      drop_table :note_types
    end

    if table_exists?(:notes)
      drop_table :notes
    end
  end
end
