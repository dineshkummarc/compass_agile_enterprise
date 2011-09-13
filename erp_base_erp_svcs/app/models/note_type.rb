class NoteType < ActiveRecord::Base
  acts_as_nested_set
  include ErpTechSvcs::Utils::DefaultNestedSetMethods
  acts_as_erp_type

  has_many_polymorphic :valid_note_type_records,
               :through => :valid_note_types,
               :models => [:applications]

  belongs_to :note_type_record, :polymorphic => true
  has_many   :notes
end
