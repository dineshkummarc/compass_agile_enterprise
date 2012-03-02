::NoteType.class_eval do
  has_many_polymorphic :valid_note_type_records,
                       :through => :valid_note_types,
                       :models => [:applications]
end
