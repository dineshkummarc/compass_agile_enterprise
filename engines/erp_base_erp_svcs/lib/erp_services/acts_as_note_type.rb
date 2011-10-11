module ErpServices
  module ActsAsNoteType
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def acts_as_note_type

        has_one :note_type_record, :as => :note_type_record, :class_name => 'NoteType'
        
        extend ErpServices::ActsAsNoteType
        include ErpServices::ActsAsNoteType

      end
    end

    module SingletonMethods
    end

    module InstanceMethods
      def after_update
        self.note_type_record.save
      end

      def after_create
        self.note_type_record.save
      end

      def before_destroy
        self.note_type_record.destroy
      end

      def after_initialize()
        if (self.note_type.nil?)
          self.note_type_record = NoteType.new
          self.note_type_record.note_type_record = self
        end
      end
      
    end
  end
end

ActiveRecord::Base.send(:include, ErpServices::ActsAsNoteType)
