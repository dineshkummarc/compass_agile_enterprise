module ErpBaseErpSvcs
	module Extensions
		module ActiveRecord
			module ActsAsNoteType
				def self.included(base)
				  base.extend(ClassMethods)
				end

				module ClassMethods
				  def acts_as_note_type
            extend ErpBaseErpSvcs::Extensions::ActiveRecord::ActsAsNoteType::SingletonMethods
  					include ErpBaseErpSvcs::Extensions::ActiveRecord::ActsAsNoteType::InstanceMethods
  					
					  after_initialize :initialize_note_type
  					after_create :save_note_type
  					after_update :save_note_type
  					after_destroy :destroy_note_type
					
					  has_one :note_type_record, :as => :note_type_record, :class_name => 'NoteType'
				  end
				end

				module SingletonMethods
				end

				module InstanceMethods
				  def save_note_type
					  self.note_type_record.save
				  end

				  def destroy_note_type
					  self.note_type_record.destroy
				  end

				  def initialize_note_type
					  if (self.note_type_record.nil?)
					    note_type_record = NoteType.new
					    self.note_type_record = note_type_record
					    self.note_type_record.note_type_record = self
					  end
				  end
				  
				end
			end
		end
	end
end
