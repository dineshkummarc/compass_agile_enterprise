module ErpServices::Category
  module ActsAsCategory
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def acts_as_category

        has_one :category, :as => :category_record
        
        extend ActsAsCategory::SingletonMethods
        include ActsAsCategory::InstanceMethods

      end
    end

    module SingletonMethods
    end

    module InstanceMethods
      def method_missing(name, *args)
         if self.category.respond_to?(name)
           self.category.send(name, *args)
         else
           super
         end
       end

      def after_update
        self.category.save
      end

      def after_create
        self.category.save
      end

      def before_destroy
        self.category.destroy
      end

      def after_initialize()
        if (self.category.nil?)
          category = Category.new
          self.category = category
          category.category_record = self
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, ErpServices::Category::ActsAsCategory)
