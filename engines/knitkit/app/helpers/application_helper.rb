# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def theme_stylesheet_path(theme, source)
    theme = @controller.site.themes.find_by_theme_id(theme) unless theme.is_a?(Theme)
    theme_compute_public_path(theme, source, theme.url + '/stylesheets', 'css')
  end
  alias_method :theme_path_to_stylesheet, :theme_stylesheet_path

  def theme_stylesheet_link_tag(theme_id, *sources)
    theme = @controller.site.themes.find_by_theme_id(theme_id)
    return("could not find theme with the id #{theme_id}") unless theme

    options = sources.extract_options!.stringify_keys
    cache   = options.delete("cache")
    recursive = options.delete("recursive")

    if ActionController::Base.perform_caching && cache
      joined_stylesheet_name = (cache == true ? "all" : cache) + ".css"
      joined_stylesheet_path = File.join(theme.path + '/stylesheets', joined_stylesheet_name)
      
      paths = theme_compute_stylesheet_paths(theme, sources, recursive)
      theme_write_asset_file_contents(theme, joined_stylesheet_path, paths) unless File.exists?(joined_stylesheet_path)
      theme_stylesheet_tag(theme, joined_stylesheet_name, options)
    else
      theme_expand_stylesheet_sources(theme, sources, recursive).collect do |source|
        theme_stylesheet_tag(theme, source, options)
      end.join("\n")
    end
  end
  
  def theme_javascript_path(theme, source)
    theme = @controller.site.themes.find_by_theme_id(theme) unless theme.is_a?(Theme)
    theme_compute_public_path(theme, source, theme.url + '/javascripts', 'js')
  end
  alias_method :theme_path_to_javascript, :theme_javascript_path

  def theme_javascript_include_tag(theme_id, *sources)
    theme = @controller.site.themes.find_by_theme_id(theme_id)
    return("could not find theme with the id #{theme_id}") unless theme

    options = sources.extract_options!.stringify_keys
    cache   = options.delete("cache")
    recursive = options.delete("recursive")

    if ActionController::Base.perform_caching && cache
      joined_javascript_name = (cache == true ? "all" : cache) + ".js"
      joined_javascript_path = File.join(theme.path + '/javascripts', joined_javascript_name)

      paths = theme_compute_javascript_paths(theme, sources, recursive)
      theme_write_asset_file_contents(theme, joined_javascript_path, paths) unless File.exists?(joined_javascript_path)
      theme_javascript_src_tag(theme, joined_javascript_name, options)
    else
      theme_expand_javascript_sources(theme, sources, recursive).collect do |source|
        theme_javascript_src_tag(theme, source, options)
      end.join("\n")
    end
  end
  
  private
    def theme_compute_public_path(theme, source, dir, ext = nil, include_host = true)
      has_request = @controller.respond_to?(:request)

      if ext && (File.extname(source).blank? || File.exist?(File.join(theme.path, dir, "#{source}.#{ext}")))
        source += ".#{ext}"
      end

      unless source =~ %r{^[-a-z]+://}
        source = "/#{dir}/#{source}" unless source[0] == ?/

        source = theme_rewrite_asset_path(theme, source)

        if has_request && include_host
          unless source =~ %r{^#{ActionController::Base.relative_url_root}/}
            source = "#{ActionController::Base.relative_url_root}#{source}"
          end
        end
      end

      if include_host && source !~ %r{^[-a-z]+://}
        host = compute_asset_host(source)

        if has_request && host.present? && host !~ %r{^[-a-z]+://}
          host = "#{@controller.request.protocol}#{host}"
        end

        "#{host}#{source}"
      else
        source
      end
    end
    
    def theme_stylesheet_tag(theme, source, options)
      options = { "rel" => "stylesheet", "type" => Mime::CSS, "media" => "screen",
                  "href" => html_escape(theme_path_to_stylesheet(theme, source)) }.merge(options)
      tag("link", options, false, false)
    end
    
    def theme_javascript_src_tag(theme, source, options)
      options = { "type" => Mime::JS, "src" => theme_path_to_javascript(theme, source) }.merge(options)
      content_tag("script", "", options)
    end

    def theme_compute_stylesheet_paths(theme, *args)
      theme_expand_stylesheet_sources(theme, *args).collect do |source|
        theme_compute_public_path(theme, source, theme.url + '/stylesheets', 'css', false)
      end
    end
    
    def theme_compute_javascript_paths(theme, *args)
      theme_expand_javascript_sources(theme, *args).collect do |source|
        theme_compute_public_path(theme, source, theme.url + '/javascripts', 'js', false)
      end
    end
    
    def theme_expand_javascript_sources(theme, sources, recursive = false)
      if sources.include?(:all)
        all_javascript_files = collect_asset_files(theme.path + '/javascripts', ('**' if recursive), '*.js').uniq
      else
        sources.collect { |source| determine_source(source, {}) }.flatten
      end
    end

    def theme_expand_stylesheet_sources(theme, sources, recursive)
      if sources.first == :all
        collect_asset_files(theme.path + '/stylesheets', ('**' if recursive), '*.css')
      else
        sources.collect do |source|
          determine_source(source, {})
        end.flatten
      end
    end
end
