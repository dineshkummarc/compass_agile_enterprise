::ErpApp::Widgets::Base.class_eval do
  private

  def add_view_paths
    #set default view paths
    cached_resolver = ErpApp::Widgets::Base.view_resolver_cache.find{|resolver| resolver.to_path == File.join(locate,"/views")}
    if cached_resolver.nil?
      resolver = ActionView::OptimizedFileSystemResolver.new(File.join(locate,"/views"))
      prepend_view_path(resolver)
      ErpApp::Widgets::Base.view_resolver_cache << resolver
    else
      prepend_view_path(cached_resolver)
    end

    #set overrides by themes
    current_theme_paths.each do |theme|
      resolver = case ErpTechSvcs::FileSupport.options[:storage]
      when :s3
        ErpTechSvcs::FileSupport::S3Manager.reload
        path = "/#{theme[:url]}/widgets/#{self.name}"
        cached_resolver = ErpApp::Widgets::Base.view_resolver_cache.find{|cached_resolver| cached_resolver.to_path == path}
        if cached_resolver.nil?
          resolver = ActionView::S3Resolver.new(path)
          ErpApp::Widgets::Base.view_resolver_cache << resolver
          resolver
        else
          cached_resolver
        end
      when :filesystem
        path = "#{theme[:path]}/widgets/#{self.name}"
        cached_resolver = ErpApp::Widgets::Base.view_resolver_cache.find{|cached_resolver| cached_resolver.to_path == path}
        if cached_resolver.nil?
          resolver = ActionView::OptimizedFileSystemResolver.new(path)
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
