module Rails
	Engine.class_eval do
	  
	  def load_widgets
	    require_widgets_and_helpers(self.root.to_s)
	  end
	  
	  def load_root_widgets
	    require_widgets_and_helpers(Rails.root.to_s)
	  end
	  
	  def require_widgets_and_helpers(path)
	    widgets = []
	    widgets_path = File.join(path,"/app/widgets/")
	    widgets = Dir.entries(widgets_path) if File.exists? widgets_path
	    widgets.delete_if{|name| name =~ /^\./}
	    widgets.each do |widget|
	      load File.join(widgets_path,widget,'base.rb')
	      #load helpers
	      if File.exists? File.join(widgets_path,widget,'helpers')
	        load_view_helpers File.join(widgets_path,widget,'helpers','view') if File.exists? File.join(widgets_path,widget,'helpers','view')
	        load_controller_helpers(File.join(widgets_path,widget,'helpers','controller'),widget) if File.exists? File.join(widgets_path,widget,'helpers','controller')
        end
	    end
	  end
	  
	  def load_view_helpers(path)
	    helpers = Dir.entries(path)
	    helpers.delete_if{|name| name =~ /^\./}
	    helpers.each do |helper|
	      load File.join(path,helper)
	      ActionView::Base.class_eval do
          include File.basename(helper, ".rb").classify.constantize
        end
	    end
	  end
	  
	  def load_controller_helpers(path, widget)
	    helpers = Dir.entries(path)
	    helpers.delete_if{|name| name =~ /^\./}
	    helpers.each do |helper|
	      load File.join(path,helper)
	      "Widgets::#{widget.classify}::Base".constantize.class_eval do
	        include File.basename(helper, ".rb").classify.constantize
	      end
	    end
	  end
	  
	end
end