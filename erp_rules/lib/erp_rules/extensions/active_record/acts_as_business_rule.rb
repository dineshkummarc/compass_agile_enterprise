module ErpRules
  module Extensions
    module ActiveRecord
      module ActsAsBusinessRule
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def acts_as_business_rule
            extend ActsAsBusinessRule::SingletonMethods
            include ActsAsBusinessRule::InstanceMethods
          end
        end

        module InstanceMethods
          def is_match? ctx
          end

        end

        module SingletonMethods
          def get_matches! ctx
          end
        end

      end
    end
  end
end
