class AddValidNoteTypes < ActiveRecord::Migration
  def self.up
    unless table_exists?(:valid_note_types)
      create_table   :valid_note_types do |t|
        t.references :valid_note_type_record, :polymorphic => true
        t.references :note_type

        t.timestamps
      end

      add_index :valid_note_types, [:valid_note_record_id, :valid_note_record_type], :name => "valid_note_type_record_idx" 
      add_index :valid_note_types, :note_type_id
    end
  end

  def self.down
    if table_exists?(:valid_note_types)
      drop_table :valid_note_types
    end
  end
end
