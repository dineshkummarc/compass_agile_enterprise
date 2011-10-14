module ThemeSupport
  class Cache
    cattr_accessor :theme_paths
  end

  module ActionController
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
        
        # write_inheritable_attribute :force_template_types, options[:force_template_types] || []
      end

      def acts_as_themed_controller?
        included_modules.include?(ThemeSupport::ActionController::InstanceMethods)
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
        ThemeSupport::Cache.theme_paths = [] if ThemeSupport::Cache.theme_paths.nil?
        if respond_to?(:current_theme_paths)
          paths = current_theme_paths.map do |theme|
            case TechServices::FileSupport.options[:storage]
            when :s3
              TechServices::FileSupport::S3Manager.reload
              path = "/#{theme[:url]}/templates"
            when :filesystem
              path = "#{theme[:path]}/templates"
            end
            theme = ThemeSupport::Cache.theme_paths.find{|path| path.path == path}
            if theme.nil?
              theme = ActionView::ReloadableTemplate::ReloadablePath.new(path)
              ThemeSupport::Cache.theme_paths << theme
            end
            theme
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

ActionController::Base.send :include, ThemeSupport::ActionController