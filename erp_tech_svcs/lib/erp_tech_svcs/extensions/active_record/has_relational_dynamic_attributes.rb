module ErpTechSvcs
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
          def find_by_value(value, *type_iids)
            arel_query = AttributeValue.where('attributed_record_type = ?', self.name)
                                       .where(AttributeValue.arel_table[:value].matches("%#{value}%"))

            or_clauses = nil
            type_iids.each do |type_iid|
              type = AttributeType.find_by_internal_identifier(type_iid)
              raise "Attribute Type '#{type_iid}' does not exist" if type.nil?
              or_clauses = or_clauses.nil? ? AttributeValue.arel_table[:attribute_type_id].eq(type.id) : or_clauses.or(AttributeValue.arel_table[:attribute_type_id].eq(type.id))
            end
            
            arel_query = arel_query.where(or_clauses) if or_clauses
            arel_query.all.collect(&:attributed_record)
          end
        end

        module InstanceMethods
          def update_or_create_attribute(value, type, data_type)
            if self.has_attribute_value_of_type?(type)
              update_first_attribute_value_of_type(value, type)
            else
              add_attribute(value, type, data_type)
            end
          end

          def update_first_attribute_value_of_type(value, type)
            attribute_type = AttributeType.find_by_internal_identifier(type)
            attribute_value = self.attribute_values.where(:attribute_type_id => attribute_type.id).first
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

          private

          def add_attribute(value, type, data_type)
            attribute_type = AttributeType.find_by_internal_identifier(type)
            attribute_type = AttributeType.create(:description => type, :data_type => data_type) unless attribute_type
            attribute_value = AttributeValue.create(:value => value, :attribute_type => attribute_type)
            self.attribute_values << attribute_value
          end

        end
        
      end#HasRelationalDynamicAttributes
    end#ActiveRecord
  end#Extensions
end#ErpTechSvcs