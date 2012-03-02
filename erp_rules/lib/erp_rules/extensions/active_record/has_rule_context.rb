module ErpRules
  module Extensions
    module ActiveRecord
    #this module will be mixed into models in order
    #to construct their execution context
      module HasRuleContext
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def has_rule_context
            extend HasRuleContext::SingletonMethods
            include HasRuleContext::InstanceMethods
          end
        end

        module InstanceMethods

          def get_context()
            #self.find_by_internal_identifier(iid)
            attributes
          end
        end

        module SingletonMethods
        end
      end
    end
  end
end
