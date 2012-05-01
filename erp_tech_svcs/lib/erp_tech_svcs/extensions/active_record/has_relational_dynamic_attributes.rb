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

            before_save :assign_dynamic_attribute_on_save

            extend HasRelationalDynamicAttributes::SingletonMethods
            include HasRelationalDynamicAttributes::InstanceMethods
          end

        end

        module SingletonMethods
          def find_by_dynamic_attribute(value, options={})
            arel_query = AttributeValue.where('attributed_record_type = ?', self.name)
                                       .where(AttributeValue.arel_table[:value].matches("%#{value}%"))

            or_clauses = nil
            options[:type_iids].each do |type_iid|
              type = AttributeType.where('description = ? or internal_identifier = ?',type_iid,type_iid).first
              raise "Attribute Type '#{type_iid}' does not exist" if type.nil?
              or_clauses = or_clauses.nil? ? AttributeValue.arel_table[:attribute_type_id].eq(type.id) : or_clauses.or(AttributeValue.arel_table[:attribute_type_id].eq(type.id))
            end if options[:type_iids]
            
            arel_query = arel_query.where(or_clauses) if or_clauses
            arel_query = arel_query.limit(options[:limit]) if options[:limit]
            arel_query = arel_query.offset(options[:offset]) if options[:offset]
            arel_query.all.collect(&:attributed_record)
          end
        end

        module InstanceMethods
          def update_or_create_dynamic_attribute(value, type, data_type)
            if self.has_dynamic_attribute_of_type?(type)
              update_first_dynamic_attribute_value_of_type(value, type)
            else
              add_dynamic_attribute(value, type, data_type)
            end
          end

          def update_first_dynamic_attribute_value_of_type(value, type)
            attribute_type = AttributeType.where('description = ? or internal_identifier = ?', type, type).first
            attribute_value = self.attribute_values.where(:attribute_type_id => attribute_type.id).first
            attribute_value.value = value
            attribute_value.save!
          end

          def get_dynamic_attributes
            {}.tap do |hash|
              self.attribute_values.each do |value|
                hash[value.attribute_type.description] = value.value
              end
            end
          end

          def get_dynamic_value_of_type(attribute_type_iid)
            attribute_value = get_dynamic_attribute_of_type(attribute_type_iid)
            attribute_value.nil? ? nil : attribute_value.value
          end

          def get_dynamic_attribute_of_type(attribute_type_iid)
            attribute_value = self.attribute_values.includes(:attribute_type).where('attribute_types.internal_identifier = ? or attribute_types.description = ?', attribute_type_iid.to_s, attribute_type_iid.to_s).first
            attribute_value.nil? ? nil : attribute_value
          end
          
          def assign_dynamic_attribute_on_save
            #template method overridden in implementing class
          end

          def has_dynamic_attribute_of_type? (attribute_type_iid)
            !self.attribute_values.includes(:attribute_type).where('attribute_types.internal_identifier = ? or attribute_types.description = ?', attribute_type_iid.to_s, attribute_type_iid.to_s).first.nil?
          end

          def destroy_dynamic_attribute_of_type (attribute_type_iid)
            self.attribute_values.includes(:attribute_type).destroy_all("attribute_types.internal_identifier = #{attribute_type_iid.to_s} or attribute_types.description = #{attribute_type_iid.to_s}")
          end
          
          def add_dynamic_attribute(value, type, data_type)
            attribute_type = AttributeType.where('description = ? or internal_identifier = ?', type, type).first
            attribute_type = AttributeType.create(:description => type, :data_type => data_type) unless attribute_type
            attribute_value = AttributeValue.create(:value => value, :attribute_type => attribute_type)
            self.attribute_values << attribute_value
          end

        end
        
      end#HasRelationalDynamicAttributes
    end#ActiveRecord
  end#Extensions
end#ErpTechSvcs