module Knitkit
  module Extensions
    module ActiveRecord
      module ActsAsDocument
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods

          def acts_as_document
            extend ActsAsDocument::SingletonMethods
            include ActsAsDocument::InstanceMethods

            after_initialize :initialize_document
  					after_create :save_document
  					after_update :save_document
  					after_destroy :destroy_document

            has_one :document, :as => :document_record

            #from Document / FileAssets
            [:add_file, :files].each { |m| delegate m, :to => :document }

            #from relational_dynamic_attributes
            [
            :update_or_create_attribute, :update_first_attribute_value_of_type,
            :get_attributes,:get_values_of_type,:get_attribute_value_records_of_type,
            :has_attribute_value_of_type?,:destroy_values_of_type
            ].each { |m| delegate m, :to => :document }
          end

        end

        module SingletonMethods
        end

        module InstanceMethods
          def save_document
            self.document.save
				  end

				  def destroy_document
            self.document.destroy
				  end

				  def initialize_document
            if (self.document.nil?)
              self.document = Document.new
              self.document.document_record = self
            end
				  end
        end

      end#ActsAsDocument
    end#ActiveRecord
  end#Extensions
end#Knitkit
