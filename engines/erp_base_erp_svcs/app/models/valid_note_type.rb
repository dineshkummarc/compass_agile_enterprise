class ValidNoteType < ActiveRecord::Base
  belongs_to :note_type
  belongs_to :valid_note_record, :polymorphic => true
end
