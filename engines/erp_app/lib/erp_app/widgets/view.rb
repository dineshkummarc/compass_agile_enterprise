# encoding: utf-8

module ErpApp
  module Widgets
    class View < ::ActionView::Base

      # Tries to find the passed template in view_paths. Returns the view on success-
      # otherwise it will throw an ActionView::MissingTemplate exception.
      def try_picking_template_for_path(template_path)
        self.view_paths.find_template(template_path, template_format)
      end

      # this prevents cell ivars from being overwritten by same-named
      # controller ivars.
      # we'll hopefully get a cleaner way, or an API, to handle this in rails 3.
      def _copy_ivars_from_controller #:nodoc:
        if @controller
          variables = @controller.instance_variable_names
          variables -= @controller.protected_instance_variables if @controller.respond_to?(:protected_instance_variables)
          variables -= assigns.keys.collect { |key| "@#{key}" } # cell ivars override controller ivars.
          variables.each { |name| instance_variable_set(name, @controller.instance_variable_get(name)) }
        end
      end
    end
  end
end

