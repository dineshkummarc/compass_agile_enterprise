ErpApp::Widgets::Base.instance_eval do
  def render_template(view, website=nil, locals={})
    widget = Rails.application.config.erp_app.widgets.find{|item| item[:name] == self.widget_name}
    paths = widget[:view_paths]

    website.themes.active.map{ |theme| {:path => theme.path.to_s, :url => theme.url.to_s}}.each do |theme|
      paths << File.join(theme[:url],'widgets',self.widget_name,'views')
    end if website
 
    paths.reverse!
    ActionView::Base.new(paths).render(:template => view, :locals => locals)
  end

end

::ErpApp::Widgets::Base.class_eval do
  private

  def add_view_paths
    widget = Rails.application.config.erp_app.widgets.find{|item| item[:name] == self.name}

    widget[:view_paths].each do |view_path|
      cached_resolver = ErpApp::Widgets::Base.view_resolver_cache.find{|resolver| resolver.to_path == view_path}
      if cached_resolver.nil?
        resolver = ActionView::OptimizedFileSystemResolver.new(view_path)
        prepend_view_path(resolver)
        ErpApp::Widgets::Base.view_resolver_cache << resolver
      else
        prepend_view_path(cached_resolver)
      end
    end

    #set overrides by themes
    current_theme_paths.each do |theme|
      resolver = case Rails.application.config.erp_tech_svcs.file_storage
      when :s3
        path = File.join(theme[:url],'widgets',self.name,'views')
        cached_resolver = ErpApp::Widgets::Base.view_resolver_cache.find{|cached_resolver| cached_resolver.to_path == path}
        if cached_resolver.nil?
          resolver = ActionView::S3Resolver.new(path)
          ErpApp::Widgets::Base.view_resolver_cache << resolver
          resolver
        else
          cached_resolver
        end
      when :filesystem
        path = File.join(theme[:path],'widgets',self.name,'views')
        cached_resolver = ErpApp::Widgets::Base.view_resolver_cache.find{|cached_resolver| cached_resolver.to_path == path}
        if cached_resolver.nil?
          resolver = ActionView::ThemeFileResolver.new(path)
          ErpApp::Widgets::Base.view_resolver_cache << resolver
          resolver
        else
          cached_resolver
        end
      end
      prepend_view_path(resolver)
    end
  end

  def current_themes
    @website = Website.find_by_host(request.host_with_port) if @website.nil?
    @website.themes.active if @website
  end

  def current_theme_paths
    current_themes ? current_themes.map { |theme| {:path => theme.path.to_s, :url => theme.url.to_s}} : []
  end

end
