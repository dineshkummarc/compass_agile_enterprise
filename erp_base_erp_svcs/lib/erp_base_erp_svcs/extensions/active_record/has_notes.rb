module ErpBaseErpSvcs
	module Extensions
		module ActiveRecord
			module HasNotes
				def self.included(base)
				  base.extend(ClassMethods)
				end

				module ClassMethods
				  def has_notes

            has_many :notes, :as => :noted_record, :dependent => :delete_all do
              def by_type(note_type)
                find_by_note_type_id(note_type.id)
              end
            end
					
            extend ErpBaseErpSvcs::Extensions::ActiveRecord::HasNotes
            include ErpBaseErpSvcs::Extensions::ActiveRecord::HasNotes

				  end
				end

				module SingletonMethods
				end

				module InstanceMethods
				end
			end
		end
	end
end
