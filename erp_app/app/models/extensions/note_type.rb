class ::NoteType < ActiveRecord::Base
  has_many_polymorphic :valid_note_type_records,
                       :through => :valid_note_types,
                       :models => [:applications]
end
