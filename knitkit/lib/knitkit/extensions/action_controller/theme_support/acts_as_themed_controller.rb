module Knitkit
  module Extensions
    module ActionController
      module ThemeSupport
        module ActsAsThemedController
          def self.included(base)
            base.class_eval do
              extend ActMacro
              delegate :acts_as_themed_controller?, :to => "self.class"
            end
          end

          module ActMacro
            def acts_as_themed_controller(options = {})
              before_filter :add_theme_view_paths
              write_inheritable_attribute :current_themes, options[:current_themes] || []

              return if acts_as_themed_controller?
              include InstanceMethods
            end

            def acts_as_themed_controller?
              included_modules.include?(Knitkit::Extensions::ActionController::ThemeSupport::ActsAsThemedController::InstanceMethods)
            end
          end

          module InstanceMethods
            def current_themes
              @current_themes ||= case accessor = self.class.read_inheritable_attribute(:current_themes)
              when Symbol then accessor == :current_themes ? raise("screwed") : send(accessor)
              when Proc   then accessor.call(self)
              else accessor
              end
            end

            def add_theme_view_paths
              if respond_to?(:current_theme_paths)
                paths = current_theme_paths.map do |theme|
                  case ErpTechSvcs::FileSupport.options[:storage]
                  when :s3
                    ErpTechSvcs::FileSupport::S3Manager.reload
                    "/#{theme[:url]}/templates"
                  when :filesystem
                    "#{theme[:path]}/templates"
                  end
                end
                prepend_view_path(paths) unless paths.empty?
              end
            end

            def current_theme_paths
              current_themes ? current_themes.map { |theme| {:path => theme.path.to_s, :url => theme.url.to_s}} : []
            end

            def authorize_template_extension!(template, ext)
              return if allowed_template_type?(ext)
              raise ThemeSupport::TemplateTypeError.new(template, force_template_types)
            end

            def allowed_template_type?(ext)
              force_template_types.blank? || force_template_types.include?(ext)
            end
          end
        end
      end
    end
  end
end