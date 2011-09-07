module ErpBaseErpSvcs
	module Extensions
		module ActiveRecord
			module ActsAsCategory
				def self.included(base)
				  base.extend(ClassMethods)
				end

				module ClassMethods
				  def acts_as_category
            extend ErpBaseErpSvcs::Extensions::ActiveRecord::ActsAsCategory::SingletonMethods
  					include ErpBaseErpSvcs::Extensions::ActiveRecord::ActsAsCategory::InstanceMethods
  					
					  after_initialize :initialize_category
  					after_create :save_category
  					after_update :save_category
  					after_destroy :destroy_category
					
					  has_one :category, :as => :category_record
				  end
				end

				module SingletonMethods
				end

				module InstanceMethods
				  def method_missing(name, *args)
            self.category.respond_to?(name) ? self.category.send(name, *args) : super
				  end

				  def save_category
            self.category.save
				  end

				  def destroy_category
            self.category.destroy
				  end

				  def initialize_category
            if (self.category.nil?)
              category = Category.new
              self.category = category
              category.category_record = self
            end
				  end
				end
			end
		end
	end
end
