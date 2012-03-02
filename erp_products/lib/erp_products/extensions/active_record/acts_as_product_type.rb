module ErpProducts
	module Extensions
		module ActiveRecord
			module ActsAsProductType

        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def acts_as_product_type()
            extend ActsAsProductType::SingletonMethods
            include ActsAsProductType::InstanceMethods

            after_initialize :initialize_product_type
            after_create :save_product_type
            after_update :save_product_type
            after_destroy :destroy_product_type

            has_one :product_type, :as => :product_type_record

            [:children, :description, :description=].each do |m| delegate m, :to => :product_type end

            def self.find_roots
              ProductType.find_roots
            end

            def self.find_children(parent_id = nil)
              ProductType.find_children(parent_id)
            end
          end
        end

        module SingletonMethods
        end

        module InstanceMethods
          def initialize_product_type
            if self.new_record? && self.product_type.nil?
              product_type = ProductType.new
              self.product_type = product_type
              product_type.save
              self.save
            end
          end

          def save_product_type
            self.product_type.save
          end

          def destroy_product_type
            self.product_type.destroy if (self.product_type && !self.product_type.frozen?)
          end
        end

      end
    end
  end
end