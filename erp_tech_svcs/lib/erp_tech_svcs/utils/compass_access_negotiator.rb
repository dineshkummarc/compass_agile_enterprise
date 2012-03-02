module ErpTechSvcs
  module Utils
    module CompassAccessNegotiator

      def has_capability?(model, capability_type, resource)
        result = true
        result = model.user_has_capability?(capability_type.to_s, resource, self) if model.has_capabilities?
        result
      end

      def with_capability(model, capability_type, resource, &block)
        if model.has_capabilities?
          if model.user_has_capability?(capability_type.to_s, resource, self)
            yield
          else
            raise ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability
          end
        else
          yield
        end
      end

      def has_access_to_widget?(widget)
        widget.has_access?(self)
      end

      def valid_widgets(application)
        widgets = []
        application.widgets.each do |widget|
          widgets << widget if self.has_access_to_widget?(widget)
        end
        widgets
      end
      
      module Errors
        class CapabilityDoesNotExist < StandardError 
          def to_s
            "Capability does not exist."
          end
        end

        class CapabilityTypeDoesNotExist < StandardError
          def to_s
            "Capability type does not exist."
          end
        end

        class CapabilityAlreadytExists < StandardError
          def to_s
            "Capability already exists."
          end
        end

        class UserDoesNotHaveCapability < StandardError
          def to_s
            "User does not have capability."
          end
        end
      end
      
    end#CompassAccessNegotiator
  end#Utils
end#ErpTechSvcs
