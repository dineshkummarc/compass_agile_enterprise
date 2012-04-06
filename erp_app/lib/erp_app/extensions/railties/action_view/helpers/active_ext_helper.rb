module ErpApp
  module Extensions
    module Railties
      module ActionView
        module Helpers
          module ActiveExtHelper
            #active_ext helper methods
            def active_ext_close_button(options={})
              raw "<input type=\"button\" class=\"#{options[:class]}\" value=\"Close\" onclick=\"parent.Compass.ErpApp.Shared.ActiveExt.closeWindow('#{@model.class.to_s.underscore + "_" + @model.id.to_s}')\" />"
            end

          end#ActiveExtHelper
        end#Helpers
      end#ActionView
    end#Railties
  end#Extensions
end#ErpApp
