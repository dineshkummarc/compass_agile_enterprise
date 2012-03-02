module ErpRules
  module Extensions
    module ActiveRecord
      module ActsAsSearchFilter

        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def acts_as_search_filter
            extend ActsAsSearchFilter::SingletonMethods
            include ActsAsSearchFilter::InstanceMethods
          end
        end

        module InstanceMethods
        end

        module SingletonMethods
          def get_search_filters ctx
          end
        end
      end
    end
  end
end

