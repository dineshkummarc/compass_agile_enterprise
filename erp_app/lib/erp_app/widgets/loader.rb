module ErpApp
  module Widgets
    class Loader
      class << self
        def load_compass_ae_widgets(engine)
          require_widgets_and_helpers(engine.root)
          load_widget_extensions(engine)
        end

        def load_root_widgets
          require_widgets_and_helpers(Rails.root.to_s)
        end

        private

        def require_widgets_and_helpers(path)
          widgets = []
          widgets_path = File.join(path,"/app/widgets/")
          widgets = Dir.entries(widgets_path) if File.exists? widgets_path
          widgets.delete_if{|name| name =~ /^\./}
          widgets.each do |widget_name|
            widget_hash = Rails.application.config.erp_app.widgets.find{|item| item[:name] == widget_name}
            if widget_hash.nil?
              widget_hash = {
                :name => widget_name,
                :path => File.join(widgets_path,widget_name),
                :view_paths => [File.join(widgets_path,widget_name,'views')],
                :view_files => []
              }
              Rails.application.config.erp_app.widgets << widget_hash
            end
            
            require_dependency File.join(widget_hash[:path],'base.rb')
            #load helpers
            if File.exists? File.join(widget_hash[:path],'helpers')
              load_widget_view_helpers File.join(widget_hash[:path],'helpers','view') if File.directory? File.join(widget_hash[:path],'helpers','view')
              load_widget_controller_helpers(File.join(widget_hash[:path],'helpers','controller'),widget_hash) if File.directory? File.join(widget_hash[:path],'helpers','controller')
            end
            #get all view files for theme generation
            get_widget_view_files(widget_hash, widget_hash[:view_paths].first)
            #load any rails root extensions
            load_root_widget_extensions(widget_hash)
          end
        end

        def load_widget_view_helpers(path)
          helpers = Dir.entries(path)
          helpers.delete_if{|name| name =~ /^\./}
          helpers.each do |helper|
            require_dependency File.join(path,helper)
            ActionView::Base.send(:include, File.basename(helper, ".rb").classify.constantize)
          end
        end

        def load_widget_controller_helpers(path, widget_hash)
          helpers = Dir.entries(path)
          helpers.delete_if{|name| name =~ /^\./}
          helpers.each do |helper|
            require_dependency File.join(path,helper)
            "Widgets::#{widget_hash[:name].classify}::Base".constantize.send(:include, File.basename(helper, ".rb").classify.constantize)
          end
        end

        def get_widget_view_files(widget_hash, view_path)
          file_support = ErpTechSvcs::FileSupport::Base.new
          file_support.build_tree(view_path)[:children].each do |node|
            if node[:leaf]
              view_file = widget_hash[:view_files].find{|item| item[:name] == node[:text]}
              if view_file.nil?
                widget_hash[:view_files] << {:name => node[:text], :path => node[:id]}
              else
                view_file[:path] = node[:id]
              end
            else
              get_widget_view_files(widget_hash, node[:id])
            end
          end
        end

        def load_widget_extensions(engine)
          widgets_path = File.join(engine.root,"lib",engine.railtie_name,"extensions/widgets")
          widgets = File.directory?(widgets_path) ? Dir.entries(widgets_path) : []
          widgets.delete_if{|name| name =~ /^\./}

          widgets.each do |widget_name|
            widget_hash = Rails.application.config.erp_app.widgets.find{|item| item[:name] == widget_name}
            #load any extensions to existing widgets
            Dir.glob(File.join(widgets_path,widget_name,"*.rb")).each do |file|
              require_dependency file
            end

            #add any additional view paths to widgets
            if File.directory?(File.join(widgets_path,widget_name,'views'))
              view_path = File.join(widgets_path,widget_name,'views')
              widget_hash[:view_paths] << view_path
              #get all view files for theme generation
              get_widget_view_files(widget_hash, view_path)
            end

            #overwrite with any extensions in rails root
            load_root_widget_extensions(widget_hash)
          end
 
        end

        def load_root_widget_extensions(widget_hash)
          if File.directory?(File.join(Rails.root,"lib/extensions/widgets",widget_hash[:name]))
            Dir.glob(File.join(Rails.root,"lib/extensions/widgets",widget_hash[:name],"*.rb")).each do |file|
              require_dependency file
            end

            #add any additional view paths to widgets
            if File.directory?(File.join(Rails.root,"lib/extensions/widgets",widget_hash[:name],'views'))
              view_path = File.join(Rails.root,"lib/extensions/widgets",widget_hash[:name],'views')
              widget_hash = Rails.application.config.erp_app.widgets.find{|item| item[:name] == widget_hash[:name]}
              widget_hash[:view_paths] << view_path
              #get all view files for theme generation
              get_widget_view_files(widget_hash, view_path)
            end
          end#make sure folder exists
        end
        
      end#self
    end#Loader
  end#Widgets
end#ErpApp
