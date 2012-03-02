module Knitkit
  module Extensions
    module ActiveRecord
      module HasRelationalDynamicAttributes
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods

          def has_relational_dynamic_attributes
            has_many :attribute_values, :as => :attributed_record, :dependent => :destroy

            before_save :assign_attribute_on_save

            extend HasRelationalDynamicAttributes::SingletonMethods
            include HasRelationalDynamicAttributes::InstanceMethods
          end

        end

        module SingletonMethods
        end

        module InstanceMethods

          def update_or_create_attribute(value, type, data_type)
            if self.has_attribute_value_of_type?(type)
              update_first_attribute_value_of_type(value, type)
            else
              add_attribute(value, type, data_type)
            end
          end

          def add_attribute(value, type, data_type)
            attribute_type = AttributeType.find_by_internal_identifier(type)
            attribute_type = AttributeType.create(:description => type, :data_type => data_type) unless attribute_type

            attribute_value = AttributeValue.new(:value => value)
            attribute_type.attribute_values << attribute_value
            self.attribute_values << attribute_value
            attribute_value.save
          end

          def update_first_attribute_value_of_type(value, type)
            attribute_type = AttributeType.find_by_internal_identifier(type)
            attribute_value = AttributeValue.where(:attribute_type_id => attribute_type.id, :attributed_record_id => self.id).first
            attribute_value.value = value
            attribute_value.save!
          end

          def get_attributes
            #template method overridden in implementing class
            attributes_hash = {}
            values = self.attribute_values
            
            values.each do |value|
              attributes_hash[value.attribute_type.internal_identifier.to_sym] = []
            end

            values.each do |value|
              attributes_hash[value.attribute_type.internal_identifier.to_sym] << value.value
            end
            attributes_hash
          end

          def get_values_of_type(attribute_type_iid)
            values = []
            self.attribute_values.each do |value|
              values << value.value if value.attribute_type.internal_identifier == attribute_type_iid
            end
            values
          end

          def get_attribute_value_records_of_type(attribute_type_iid)
            values = []
            self.attribute_values.each do |value|
              values << value if value.attribute_type.internal_identifier == attribute_type_iid
            end
            values
          end
          
          def assign_attribute_on_save
            #template method overridden in implementing class
          end

          def has_attribute_value_of_type? (attribute_type_iid)
            has_existing_value_of_type = false
            self.attribute_values.each do |value|
              if value.attribute_type.internal_identifier == attribute_type_iid
                has_existing_value_of_type = true
              end
            end
            has_existing_value_of_type
          end

          def destroy_values_of_type (attribute_type_iid)
            self.attribute_values.each do |value|
              if value.attribute_type.internal_identifier == attribute_type_iid
                value.destroy
              end
            end
          end

        end
      end
    end
  end
end