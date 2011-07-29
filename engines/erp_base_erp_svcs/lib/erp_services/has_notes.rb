module ErpServices
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
        
        extend ErpServices::HasNotes
        include ErpServices::HasNotes

      end
    end

    module SingletonMethods
    end

    module InstanceMethods

    end
  end
end

ActiveRecord::Base.send(:include, ErpServices::HasNotes)
