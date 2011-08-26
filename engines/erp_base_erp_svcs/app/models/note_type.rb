class NoteType < ActiveRecord::Base
  acts_as_nested_set
  acts_as_erp_type

  has_many :notes
end
